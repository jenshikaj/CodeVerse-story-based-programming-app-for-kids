import 'package:codeverse/src/common_widgets/form/form_header_widget.dart';
import 'package:codeverse/src/constants/colors.dart';
import 'package:codeverse/src/constants/image_strings.dart';
import 'package:codeverse/src/constants/sizes.dart';
import 'package:codeverse/src/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:codeverse/src/features/authentication/screens/login/login_screen.dart'; // Import Login Screen

class ForgetPasswordMailScreen extends StatelessWidget {
  const ForgetPasswordMailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> formKey =
        GlobalKey<FormState>(); // Unique FormKey

    Future<void> checkEmailExists() async {
      try {
        // Attempt to send a password reset email
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailController.text);

        // Show snackbar and navigate to Login Screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A password reset email has been sent.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to the login screen after a short delay to ensure the snackbar is visible
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // Email not registered
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email is not registered'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (e.code == 'invalid-email') {
          // Invalid email format
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The email address is not valid.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Other errors
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: CVBackgroundColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(CVDefaultSize),
          child: Column(
            children: [
              const SizedBox(height: CVDefaultSize * 4),
              const FormHeaderWidget(
                image: CVForgetPasswordImage,
                title: CVForgetPasswordScreenTitle,
                subTitle: CVForgetMailSubTitle,
                crossAxisAlignment: CrossAxisAlignment.center,
                heightBetween: 30.0,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CVFormHeight),
              Form(
                key: formKey, // Assign the unique GlobalKey
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        label: Text(CVEmail),
                        hintText: CVEmail,
                        prefixIcon: Icon(Icons.mail_sharp),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: checkEmailExists,
                        child: const Text(CVNext),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
