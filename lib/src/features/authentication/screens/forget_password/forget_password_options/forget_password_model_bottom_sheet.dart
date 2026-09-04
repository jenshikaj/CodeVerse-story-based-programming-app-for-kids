import 'package:codeverse/src/features/authentication/screens/forget_password/forget_password_mail/forget_password_mail.dart';
import 'package:codeverse/src/features/authentication/screens/forget_password/forget_password_phone/forget_password_phone.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants/sizes.dart';
import '../../../../../constants/text_strings.dart';
import 'forget_password_button_widget.dart';

class ForgetPasswordScreen {
  static Future<dynamic> buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(CVDefaultSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              CVForgetPasswordTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              CVForgetPasswordSubTitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 30.0),
            ForgetPasswordButtonWidget(
              btnIcon: Icons.mail_outline_sharp,
              title: CVEmail,
              subTitle: CVResetViaEmail,
              onTap: () {
                Navigator.pop(context);
                Get.to(
                  () => const ForgetPasswordMailScreen(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 800),
                );
              },
            ),
            const SizedBox(height: 20.0),
            ForgetPasswordButtonWidget(
              btnIcon: Icons.mobile_friendly_sharp,
              title: CVContactNo,
              subTitle: CVForgetContactSubTitle,
              onTap: () {
                Navigator.pop(context);
                Get.to(
                  () => const ForgetPasswordPhoneScreen(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 800),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
