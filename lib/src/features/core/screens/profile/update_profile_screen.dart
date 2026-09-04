import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:codeverse/src/constants/colors.dart';
import 'package:codeverse/src/constants/sizes.dart';
import 'package:codeverse/src/constants/text_strings.dart';
import 'package:codeverse/src/features/authentication/models/user_model.dart';
import 'package:codeverse/src/features/authentication/screens/welcome/welcome_screen.dart';
import 'package:codeverse/src/features/core/controllers/profile_controller.dart';
import 'package:codeverse/src/utils/image_helper.dart';
import 'package:codeverse/src/utils/snackbars.dart';
import 'package:codeverse/src/utils/validators.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late final ProfileController _controller;

  late Future<UserModel?> _userFuture;

  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phoneNo = TextEditingController();

  bool _fieldsPopulated = false;
  bool _saving = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    _userFuture = _controller.getUserData();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phoneNo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CVBackgroundColor,
      appBar: AppBar(
        backgroundColor: CVBackgroundColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            LineAwesomeIcons.angle_left_solid,
            color: CVAccentColor,
          ),
        ),
        title: Text(
          CVEditProfile,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: CVAccentColor2),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Please complete your profile first.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!_fieldsPopulated) {
            _fullName.text = user.fullName;
            _email.text = user.email;
            _phoneNo.text = user.phoneNo;
            _fieldsPopulated = true;
          }

          return _buildForm(context, user);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(CVDefaultSize),
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image(
                      image: profileImageProvider(user.profileImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () async {
                      await _controller.uploadProfileImage();
                      setState(() {
                        _userFuture = _controller.getUserData();
                      });
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: CVAccentColor,
                      ),
                      child: const Icon(
                        LineAwesomeIcons.camera_solid,
                        size: 20.0,
                        color: CVWhiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _fullName,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      label: Text(CVFullName),
                      prefixIcon: Icon(LineAwesomeIcons.user),
                    ),
                    validator: CVValidators.fullName,
                  ),
                  const SizedBox(height: CVFormHeight - 20),
                  TextFormField(
                    controller: _email,
                    readOnly: true,
                    decoration: const InputDecoration(
                      label: Text(CVEmail),
                      prefixIcon: Icon(LineAwesomeIcons.envelope_solid),
                      helperText: 'Your sign-in email cannot be changed here.',
                    ),
                  ),
                  const SizedBox(height: CVFormHeight - 20),
                  TextFormField(
                    controller: _phoneNo,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      label: Text(CVContactNo),
                      prefixIcon: Icon(LineAwesomeIcons.phone_alt_solid),
                    ),
                    validator: CVValidators.phone,
                  ),
                  const SizedBox(height: CVFormHeight),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (_saving || _deleting) ? null : () => _save(user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CVAccentColor,
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              CVSaveProfile,
                              style: TextStyle(color: CVWhiteColor),
                            ),
                    ),
                  ),
                  const SizedBox(height: CVFormHeight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: CVJoined,
                          style: const TextStyle(fontSize: 12.0),
                          children: [
                            TextSpan(
                              text: DateFormat('dd MMMM yyyy')
                                  .format(user.createdAt),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: (_saving || _deleting)
                            ? null
                            : () => _confirmDelete(user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          elevation: 0,
                          foregroundColor: Colors.red,
                          shape: const StadiumBorder(),
                          side: BorderSide.none,
                        ),
                        child: _deleting
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                            : const Text(CVDelete),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(UserModel user) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    try {
      final current = await _controller.getUserData();

      final updated = UserModel(
        id: user.id,
        email: user.email,
        password: user.password,
        fullName: _fullName.text.trim(),
        phoneNo: _phoneNo.text.trim(),
        profileImage: current?.profileImage ?? user.profileImage,
        createdAt: user.createdAt,
        score: current?.score ?? user.score,
      );

      await _controller.updateRecord(updated);
      if (mounted) Get.back();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete(UserModel user) async {
    if (user.id == null) {
      CVNotify.error('Could not identify your profile.');
      return;
    }

    final isGoogle = _controller.isGoogleUser;
    final passwordController = TextEditingController();

    await Get.defaultDialog(
      title: 'Delete account',
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.redAccent,
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This permanently deletes your profile, all your generated '
              'stories, and your sign-in account. It cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            if (!isGoogle) ...[
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm your password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              const Text(
                'You will be asked to confirm with Google.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
      textConfirm: 'Delete permanently',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () async {
        Get.back(); // close the dialog first
        await _runDelete(user, passwordController.text);
      },
    );

    passwordController.dispose();
  }

  Future<void> _runDelete(UserModel user, String password) async {
    setState(() => _deleting = true);

    try {
      await _controller.deleteAccount(
        userId: user.id!,
        password: password,
      );
      Get.offAll(() => const WelcomeScreen());
    } catch (_) {
      if (mounted) setState(() => _deleting = false);
    }
  }
}
