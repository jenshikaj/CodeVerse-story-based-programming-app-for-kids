import 'package:codeverse/src/constants/colors.dart';
import 'package:codeverse/src/constants/image_strings.dart';
import 'package:codeverse/src/constants/sizes.dart';
import 'package:codeverse/src/constants/text_strings.dart';
import 'package:codeverse/src/features/authentication/screens/login/login_screen.dart';
import 'package:codeverse/src/features/authentication/screens/signup/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var height = mediaQuery.size.height;
    var brightness = mediaQuery.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? CVSecondaryColor : CVBackgroundColor,
      body: Container(
          padding: const EdgeInsets.all(CVDefaultSize),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image(
                  image: const AssetImage(CVWelcomeScreenImage),
                  height: height * 0.5),
              Column(
                children: [
                  Text(
                    CVWelcomeTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    CVWelcomeSubTitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                        onPressed: () => Get.to(
                              () => const LoginScreen(),
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 800),
                            ),
                        child: Text(CVLogin.toUpperCase())),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () => Get.to(
                              () => const SignupScreen(),
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 800),
                            ),
                        child: Text(CVSignup.toUpperCase())),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
