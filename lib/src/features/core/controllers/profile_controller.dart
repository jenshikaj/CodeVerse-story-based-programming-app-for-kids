import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:codeverse/src/features/authentication/models/user_model.dart';
import 'package:codeverse/src/repository/authentication_repository/authentication_repository.dart';
import 'package:codeverse/src/repository/user_repository/user_repository.dart';
import 'package:codeverse/src/utils/snackbars.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  AuthenticationRepository get _authRepo => AuthenticationRepository.instance;
  UserRepository get _userRepo => UserRepository.instance;

  final ImagePicker _picker = ImagePicker();

  bool get isGoogleUser => _authRepo.isGoogleUser;

  Future<UserModel?> getUserData() async {
    final email = _authRepo.firebaseUser?.email;
    if (email == null) return null;
    return _userRepo.getUserDetails(email);
  }

  Future<List<UserModel>> getAllUsers() => _userRepo.allUsers();

  Future<void> updateRecord(UserModel user) async {
    try {
      await _userRepo.updateUserRecord(user);
      CVNotify.success('Profile updated.');
    } catch (e) {
      CVNotify.error(e.toString());
      rethrow;
    }
  }

  Future<void> uploadProfileImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 70,
      );
      if (picked == null) return; // cancelled, not an error

      final bytes = await picked.readAsBytes();

      if (bytes.lengthInBytes > 600 * 1024) {
        CVNotify.warning(
          'That image is too large. Please choose a smaller photo.',
        );
        return;
      }

      final user = await getUserData();
      if (user == null) {
        CVNotify.warning('Please complete your profile first.');
        return;
      }

      user.profileImage = base64Encode(bytes);
      await _userRepo.updateUserRecord(user);

      CVNotify.success('Profile photo updated.');
    } catch (e) {
      if (kDebugMode) print('uploadProfileImage failed: $e');
      CVNotify.error('Could not update your photo. Please try again.');
    }
  }

  Future<void> deleteAccount({
    required String userId,
    String? password,
  }) async {
    // Capture the email before the account disappears.
    final email = _authRepo.firebaseUser?.email;
    if (email == null) {
      CVNotify.error('You are not signed in.');
      throw 'You are not signed in.';
    }

    try {
      // 1. Prove identity.
      await _authRepo.reauthenticate(password: password);

      // 2. Their generated stories.
      await _userRepo.deleteStoriesForEmail(email);

      // 3. Their profile document.
      await _userRepo.deleteUser(userId);

      // 4. The authentication account. Last, deliberately.
      await _authRepo.deleteUserAccount();

      CVNotify.success('Your account and all your data have been deleted.');
    } catch (e) {
      if (kDebugMode) print('deleteAccount failed: $e');
      CVNotify.error(e.toString());
      rethrow;
    }
  }

  /// Kept for backwards compatibility with older call sites.
  @Deprecated('Use deleteAccount() instead - it also removes stories.')
  Future<void> deleteUser(String userId, {String? password}) =>
      deleteAccount(userId: userId, password: password);
}
