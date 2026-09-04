import 'package:codeverse/src/constants/colors.dart';
import 'package:codeverse/src/constants/sizes.dart';
import 'package:codeverse/src/constants/text_strings.dart';
import 'package:codeverse/src/features/authentication/controllers/mail_verification_controller.dart';
import 'package:codeverse/src/repository/authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class MailVerification extends StatelessWidget {
  const MailVerification({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MailVerificationController());
    return Scaffold(
        backgroundColor: CVBackgroundColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: CVDefaultSpace, vertical: CVDefaultSpace * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: CVDefaultSpace * 20),
                const Icon(LineAwesomeIcons.envelope_open, size: 100),
                const SizedBox(height: CVDefaultSpace * 2),
                Text(CVEmailVerificationTitle.tr,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: CVDefaultSpace),
                Text(
                  CVEmailVerificationSubTitle.tr,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: CVDefaultSpace * 2),
                SizedBox(
                  width: 200,
                  child: OutlinedButton(
                      child: Text(CVContinue.tr),
                      onPressed: () =>
                          controller.manuallyCheckEmailVerificationStatus()),
                ),
                const SizedBox(height: CVDefaultSpace * 2),
                TextButton(
                  onPressed: () => controller.sendVerificationEmail(),
                  child: Text(CVResendEmailLink.tr),
                ),
                TextButton(
                    onPressed: () => AuthenticationRepository.instance.logout(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LineAwesomeIcons.long_arrow_alt_left_solid),
                        const SizedBox(width: 5),
                        Text(CVBackToLogin.tr.toLowerCase()),
                      ],
                    ))
              ],
            ),
          ),
        ));
  }
}
