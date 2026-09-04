import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:codeverse/src/constants/colors.dart';
import 'package:codeverse/src/features/authentication/controllers/login_controller.dart';
import 'package:codeverse/src/utils/validators.dart';
import '../../../../constants/sizes.dart';
import '../../../../constants/text_strings.dart';
import '../forget_password/forget_password_options/forget_password_model_bottom_sheet.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscureText = true;

  final _formKey = GlobalKey<FormState>();

  late final LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      controller.login();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: CVFormHeight - 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_2_sharp),
                  labelText: CVEmail,
                  hintText: CVEmail,
                  border: OutlineInputBorder(),
                ),
                validator: CVValidators.email,
              ),
              const SizedBox(height: CVFormHeight),
              TextFormField(
                controller: controller.password,
                obscureText: _obscureText,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.fingerprint_sharp),
                  labelText: CVPassword,
                  hintText: CVPassword,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                validator: CVValidators.loginPassword,
              ),
              const SizedBox(height: CVFormHeight - 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ForgetPasswordScreen.buildShowModalBottomSheet(context);
                  },
                  child: const Text(
                    CVForgetPassword,
                    style: TextStyle(color: CVAccentColor2),
                  ),
                ),
              ),
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
                        : Text(CVLogin.toUpperCase()),
                  ),
                ),
              ),
              const SizedBox(height: CVFormHeight),
            ],
          ),
        ),
      ),
    );
  }
}
