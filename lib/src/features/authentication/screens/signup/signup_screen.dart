import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:codeverse/src/common_widgets/form/form_header_widget.dart';
import 'package:codeverse/src/constants/image_strings.dart';
import 'package:codeverse/src/constants/sizes.dart';
import 'package:codeverse/src/constants/text_strings.dart';
import 'package:codeverse/src/features/authentication/controllers/login_controller.dart';
import 'package:codeverse/src/features/authentication/screens/login/login_screen.dart';
import 'package:codeverse/src/features/authentication/screens/signup/widgets/signup_form_widget.dart';
import '../../../../constants/colors.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  void _goToLogin() {
    if (Get.previousRoute.contains('LoginScreen')) {
      Get.back();
    } else {
      Get.off(
        () => const LoginScreen(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 800),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: CVBackgroundColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(CVDefaultSize),
          child: Column(
            children: [
              const FormHeaderWidget(
                image: CVLogoImage,
                title: CVSignupTitle,
                subTitle: CVSignUpSubTitle,
                textAlign: TextAlign.center,
              ),
              const SignUpFormWidget(),
              Column(
                children: [
                  const Text("OR"),
                  const SizedBox(height: CVFormHeight - 10),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => OutlinedButton.icon(
                        icon: const Image(
                          image: AssetImage(CVGoogleLogoImage),
                          width: 20.0,
                        ),
                        onPressed: controller.isGoogleLoading.value
                            ? null
                            : () => controller.googleSignIn(),
                        label: Text(
                          controller.isGoogleLoading.value
                              ? 'Signing in...'
                              : CVSignInWithGoogle,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _goToLogin,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: CVAlreadyHaveAnAccount,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          TextSpan(
                            text: CVLogin,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: CVAccentColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
