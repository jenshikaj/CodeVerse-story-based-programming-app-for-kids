import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:codeverse/src/features/authentication/screens/login/login_screen.dart';
import 'package:codeverse/src/features/authentication/screens/mail_verification/mail_verification.dart';
import 'package:codeverse/src/features/authentication/screens/splash_screen/splash_screen.dart';
import 'package:codeverse/src/features/core/screens/home/home_screen.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> _firebaseUser;
  final _phoneVerificationId = ''.obs;

  User? get firebaseUser => _firebaseUser.value;
  String get getUserID => firebaseUser?.uid ?? "";
  String get getUseEmail => firebaseUser?.email ?? "";

  bool get isGoogleUser =>
      _auth.currentUser?.providerData
          .any((p) => p.providerId == 'google.com') ??
      false;

  @override
  void onReady() {
    _firebaseUser = Rx<User?>(_auth.currentUser);
    _firebaseUser.bindStream(_auth.userChanges());
    FlutterNativeSplash.remove();
    setInitialScreen(_firebaseUser.value);
  }

  // Navigation

  void setInitialScreen(User? user) {
    if (user == null) {
      final route = Get.currentRoute;
      if (route.contains('LoginScreen') ||
          route.contains('SignupScreen') ||
          route.contains('ForgetPassword')) {
        return;
      }
      Get.offAll(() => SplashScreen());
      return;
    }

    if (user.emailVerified) {
      Get.offAll(() => const HomeScreen());
    } else {
      Get.offAll(() => const MailVerification());
    }
  }

  // Error mapping

  String _messageForCode(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password. Please try again.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'requires-recent-login':
        return 'For security, please sign in again before making this change.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different '
            'sign-in method.';
      case 'invalid-verification-code':
        return 'That verification code is incorrect.';
      case 'invalid-phone-number':
        return 'That phone number is not valid.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  // Email and password

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Login failed: ${e.code} - ${e.message}');
      throw _messageForCode(e.code);
    } catch (e) {
      if (kDebugMode) print('Login failed: $e');
      throw 'Could not sign in. Please try again.';
    }
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Signup failed: ${e.code} - ${e.message}');
      throw _messageForCode(e.code);
    } catch (e) {
      if (kDebugMode) print('Signup failed: $e');
      throw 'Could not create your account. Please try again.';
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Verification email failed: ${e.code}');
      throw _messageForCode(e.code);
    } catch (e) {
      throw 'Could not send the verification email. Please try again.';
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Password reset failed: ${e.code}');
      throw _messageForCode(e.code);
    } catch (e) {
      throw 'Could not send the reset email. Please try again.';
    }
  }

  // Google

  /// Returns null when the user backs out of the Google picker.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        throw 'Google sign-in did not return valid credentials.';
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Google sign-in failed: ${e.code} - ${e.message}');
      throw _messageForCode(e.code);
    } catch (e) {
      if (kDebugMode) print('Google sign-in failed: $e');
      throw 'Could not sign in with Google. Please try again.';
    }
  }

  // Sensitive operations

  Future<void> reauthenticate({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) throw 'You are not signed in.';

    try {
      if (isGoogleUser) {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) throw 'Sign-in was cancelled.';

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
      } else {
        if (password == null || password.isEmpty) {
          throw 'Please enter your password to continue.';
        }
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Reauthentication failed: ${e.code}');
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw 'That password is incorrect.';
      }
      throw _messageForCode(e.code);
    }
  }

  // Phone

  Future<void> phoneAuthentication(String phoneNo) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNo,
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential);
        },
        codeSent: (verificationId, resendToken) {
          _phoneVerificationId.value = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _phoneVerificationId.value = verificationId;
        },
        verificationFailed: (e) {
          if (kDebugMode) print('Phone verification failed: ${e.code}');
          throw _messageForCode(e.code);
        },
      );
    } on FirebaseAuthException catch (e) {
      throw _messageForCode(e.code);
    } catch (e) {
      throw 'Could not send the verification code. Please try again.';
    }
  }

  Future<bool> verifyOTP(String otp, String verificationId) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('OTP verification failed: ${e.code}');
      throw _messageForCode(e.code);
    } catch (e) {
      throw 'Could not verify that code. Please try again.';
    }
  }

  // Session

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      if (kDebugMode) print('Logout failed: $e');
      throw 'Unable to log out. Please try again.';
    }
  }

  /// Deletes the Firebase Auth account.
  Future<void> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'You are not signed in.';
      await user.delete();
      // Clear the Google session too
      await GoogleSignIn().signOut();
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Account deletion failed: ${e.code}');
      throw _messageForCode(e.code);
    } catch (e) {
      if (kDebugMode) print('Account deletion failed: $e');
      throw 'Could not delete your account. Please try again.';
    }
  }
}
