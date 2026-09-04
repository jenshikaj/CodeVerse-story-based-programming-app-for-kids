import 'package:codeverse/src/common_widgets/form/form_header_widget.dart';
import 'package:codeverse/src/constants/colors.dart';
import 'package:codeverse/src/constants/image_strings.dart';
import 'package:codeverse/src/constants/sizes.dart';
import 'package:codeverse/src/constants/text_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:codeverse/src/features/authentication/controllers/otp_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../forget_password_otp/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class ForgetPasswordPhoneScreen extends StatelessWidget {
  const ForgetPasswordPhoneScreen({super.key});

  Future<void> sendOtpToPhoneNumber(
      String phoneNumber, BuildContext context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // Auto-retrieve code
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        // Save verificationId for later use
        Get.find<OtpController>().setVerificationId(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto retrieval timed out
        Get.find<OtpController>().setVerificationId(verificationId);
      },
    );
  }

  Future<void> checkPhoneNumberExists(
      String phoneNumber, BuildContext context) async {
    try {
      // Check if the phone number exists in Firestore
      final usersCollection = FirebaseFirestore.instance.collection('Users');
      final userSnapshot =
          await usersCollection.where('Phone', isEqualTo: phoneNumber).get();

      if (userSnapshot.docs.isNotEmpty) {
        // Phone number exists, send OTP
        await sendOtpToPhoneNumber(phoneNumber, context);

        // Show snackbar and navigate to OTP Screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your phone for the OTP.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to OTP Screen with phone number
        Get.to(
          () => OtpScreen(phoneNumber: phoneNumber),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 800),
        );
      } else {
        // Phone number does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The phone number is not registered.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();

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
                subTitle: CVForgetContactSubTitle,
                crossAxisAlignment: CrossAxisAlignment.center,
                heightBetween: 30.0,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CVFormHeight),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        label: Text(CVContactNo),
                        hintText: CVContactNo,
                        prefixIcon: Icon(Icons.call),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => checkPhoneNumberExists(
                            phoneController.text, context),
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
