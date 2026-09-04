import 'package:codeverse/src/constants/colors.dart';
import 'package:codeverse/src/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'login_footer_widget.dart';
import 'login_form_widget.dart';
import 'login_header_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: CVBackgroundColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(CVDefaultSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LoginHeaderWidget(size: size),
              const LoginForm(),
              const LoginFooterWidget()
            ],
          ),
        ),
      ),
    );
  }
}
