import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:codeverse/src/features/authentication/controllers/signup_controller.dart';
import 'package:codeverse/src/utils/validators.dart';
import '../../../../../constants/sizes.dart';
import '../../../../../constants/text_strings.dart';

class SignUpFormWidget extends StatefulWidget {
  const SignUpFormWidget({super.key});

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  bool _obscureText = true;

  final _formKey = GlobalKey<FormState>();

  late final SignupController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<SignupController>()
        ? Get.find<SignupController>()
        : Get.put(SignupController());
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await controller.createUser();
    if (mounted) _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: CVFormHeight - 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: controller.fullName,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                label: Text(CVFullName),
                prefixIcon: Icon(Icons.person_2_sharp),
              ),
              validator: CVValidators.fullName,
            ),
            const SizedBox(height: CVFormHeight - 20),
            TextFormField(
              controller: controller.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: const InputDecoration(
                label: Text(CVEmail),
                prefixIcon: Icon(Icons.email_sharp),
              ),
              validator: CVValidators.email,
            ),
            const SizedBox(height: CVFormHeight - 20),
            TextFormField(
              controller: controller.phoneNo,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                label: Text(CVContactNo),
                prefixIcon: Icon(Icons.call),
              ),
              validator: CVValidators.phone,
            ),
            const SizedBox(height: CVFormHeight - 20),
            TextFormField(
              controller: controller.password,
              obscureText: _obscureText,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                label: const Text(CVPassword),
                prefixIcon: const Icon(Icons.fingerprint_sharp),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
              validator: CVValidators.password,
            ),
            const SizedBox(height: CVFormHeight - 10),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : _submit,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(CVSignup.toUpperCase()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
