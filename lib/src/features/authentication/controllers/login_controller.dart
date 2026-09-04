import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:codeverse/src/repository/authentication_repository/authentication_repository.dart';
import 'package:codeverse/src/utils/snackbars.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final showPassword = false.obs;
  final email = TextEditingController();
  final password = TextEditingController();

  final isLoading = false.obs;
  final isGoogleLoading = false.obs;

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }

  Future<void> login() async {
    try {
      isLoading.value = true;

      final auth = AuthenticationRepository.instance;
      await auth.loginWithEmailAndPassword(
        email.text.trim(),
        password.text,
      );

      CVNotify.success('Welcome back!');
      clearForm();
      auth.setInitialScreen(auth.firebaseUser);
    } catch (e) {
      CVNotify.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> googleSignIn() async {
    try {
      isGoogleLoading.value = true;

      final auth = AuthenticationRepository.instance;
      final credential = await auth.signInWithGoogle();

      if (credential == null) return;

      CVNotify.success('Signed in with Google');
      clearForm();
      auth.setInitialScreen(auth.firebaseUser);
    } catch (e) {
      CVNotify.error(e.toString());
    } finally {
      isGoogleLoading.value = false;
    }
  }

  void clearForm() {
    email.clear();
    password.clear();
  }
}
