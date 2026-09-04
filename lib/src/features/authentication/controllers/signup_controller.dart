import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:codeverse/src/features/authentication/models/user_model.dart';
import 'package:codeverse/src/repository/authentication_repository/authentication_repository.dart';
import 'package:codeverse/src/repository/user_repository/user_repository.dart';
import 'package:codeverse/src/utils/snackbars.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  final email = TextEditingController();
  final password = TextEditingController();
  final fullName = TextEditingController();
  final phoneNo = TextEditingController();

  final isLoading = false.obs;

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    fullName.dispose();
    phoneNo.dispose();
    super.onClose();
  }

  Future<void> createUser() async {
    final auth = AuthenticationRepository.instance;

    try {
      isLoading.value = true;

      final user = UserModel(
        email: email.text.trim(),
        password: password.text,
        fullName: fullName.text.trim(),
        phoneNo: phoneNo.text.trim(),
        createdAt: DateTime.now(),
      );

      // Step 1: the authentication account.
      await auth.createUserWithEmailAndPassword(user.email, user.password);

      // Step 2: the Firestore profile document.
      try {
        await UserRepository.instance.createUser(user);
      } catch (profileError) {
        if (kDebugMode) {
          print('Profile write failed, rolling back: $profileError');
        }
        try {
          await auth.deleteUserAccount();
        } catch (rollbackError) {
          if (kDebugMode) print('Rollback failed: $rollbackError');
        }
        rethrow;
      }

      CVNotify.success('Account created. Please verify your email.');
      clearForm();
      auth.setInitialScreen(auth.firebaseUser);
    } catch (e) {
      if (kDebugMode) print('Signup failed: $e');
      CVNotify.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> phoneAuthentication(String phoneNumber) async {
    try {
      await AuthenticationRepository.instance.phoneAuthentication(phoneNumber);
    } catch (e) {
      CVNotify.error(e.toString());
    }
  }

  void clearForm() {
    email.clear();
    password.clear();
    fullName.clear();
    phoneNo.clear();
  }
}
