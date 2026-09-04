import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:codeverse/src/constants/colors.dart';
import 'package:codeverse/src/features/authentication/models/user_model.dart';
import 'package:codeverse/src/features/core/controllers/profile_controller.dart';
import 'package:codeverse/src/features/core/screens/home/home_screen.dart';
import 'package:codeverse/src/features/core/screens/profile/update_profile_screen.dart';
import 'package:codeverse/src/features/core/screens/profile/widgets/profile_menu.dart';
import 'package:codeverse/src/repository/authentication_repository/authentication_repository.dart';
import 'package:codeverse/src/repository/user_repository/user_repository.dart';
import 'package:codeverse/src/utils/image_helper.dart';
import 'package:codeverse/src/utils/snackbars.dart';
import 'package:codeverse/src/utils/theme/theme_controller.dart';
import 'package:codeverse/src/utils/validators.dart';
import '../../../../constants/sizes.dart';
import '../../../../constants/text_strings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late final ThemeController _themeController;
  late final ProfileController _profileController;
  late Future<UserModel?> _userFuture;

  // Complete-profile form state.
  final _completeFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _savingProfile = false;

  @override
  void initState() {
    super.initState();

    _themeController = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>()
        : Get.put(ThemeController());
    _profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    _userFuture = _profileController.getUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _themeController.syncWithSystem();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _userFuture = _profileController.getUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: CVBackgroundColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _shell(
            title: 'Profile',
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) return _buildCompleteProfileForm(context);
        return _buildUserProfile(context, user);
      },
    );
  }

  Widget _shell({required String title, required Widget child}) {
    return Scaffold(
      backgroundColor: CVBackgroundColor,
      appBar: AppBar(
        backgroundColor: CVBackgroundColor,
        leading: IconButton(
          onPressed: () => Get.offAll(
            () => const HomeScreen(),
            transition: Transition.leftToRight,
            duration: const Duration(milliseconds: 800),
          ),
          icon: const Icon(
            LineAwesomeIcons.angle_left_solid,
            color: CVAccentColor,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: CVAccentColor2),
        ),
        centerTitle: true,
      ),
      body: child,
    );
  }

  // ------------------------------------------------------------------
  // Complete profile
  // ------------------------------------------------------------------

  Widget _buildCompleteProfileForm(BuildContext context) {
    return _shell(
      title: 'Complete Profile',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(CVDefaultSize),
          child: Form(
            key: _completeFormKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Just a couple of details before you get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    label: Text(CVFullName),
                    prefixIcon: Icon(LineAwesomeIcons.user),
                  ),
                  validator: CVValidators.fullName,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
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
                    onPressed: _savingProfile ? null : _saveCompleteProfile,
                    child: _savingProfile
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveCompleteProfile() async {
    if (!(_completeFormKey.currentState?.validate() ?? false)) return;

    final email = AuthenticationRepository.instance.firebaseUser?.email;
    if (email == null) {
      CVNotify.error('You need to be signed in to save a profile.');
      return;
    }

    setState(() => _savingProfile = true);

    try {
      await UserRepository.instance.createUser(
        UserModel(
          email: email,
          password: '',
          fullName: _nameController.text.trim(),
          phoneNo: _phoneController.text.trim(),
          createdAt: DateTime.now(),
        ),
      );

      CVNotify.success('Profile saved.');
      _reload();
    } catch (e) {
      CVNotify.error(e.toString());
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  // ------------------------------------------------------------------
  // Profile view
  // ------------------------------------------------------------------

  Widget _buildUserProfile(BuildContext context, UserModel user) {
    return Obx(() {
      final isDark = _themeController.isDarkMode.value;

      return _shell(
        title: 'Profile',
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: CVAccentColor,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            LineAwesomeIcons.pencil_alt_solid,
                            size: 20.0,
                            color: CVWhiteColor,
                          ),
                          onPressed: () async {
                            await Get.to(() => const UpdateProfileScreen());
                            _reload();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isDark ? CVWhiteColor : CVDarkColor,
                      ),
                ),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? CVWhiteColor : CVDarkColor,
                      ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Get.to(
                        () => const UpdateProfileScreen(),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 800),
                      );
                      _reload();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CVAccentColor,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(color: CVWhiteColor),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Divider(color: Colors.transparent),
                const SizedBox(height: 10),
                ProfileMenuWidget(
                  title: "Settings",
                  icon: LineAwesomeIcons.cog_solid,
                  onPress: () => CVNotify.info('Settings are coming soon.'),
                ),
                const SizedBox(height: 10),
                ProfileMenuWidget(
                  title: "Information",
                  icon: LineAwesomeIcons.info_solid,
                  onPress: () => CVNotify.info(
                    'CodeVerse helps children learn programming through '
                    'stories and quizzes.',
                    title: 'About CodeVerse',
                  ),
                ),
                const SizedBox(height: 10),
                ProfileMenuWidget(
                  title: "Logout",
                  icon: LineAwesomeIcons.sign_out_alt_solid,
                  textColor: const Color.fromARGB(255, 207, 74, 65),
                  endIcon: false,
                  onPress: _confirmLogout,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _confirmLogout() async {
    Get.defaultDialog(
      title: 'Log out',
      middleText: 'Are you sure you want to log out?',
      textConfirm: 'Yes',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: CVAccentColor,
      onConfirm: () async {
        Get.back();
        try {
          await AuthenticationRepository.instance.logout();
        } catch (e) {
          CVNotify.error(e.toString());
        }
      },
    );
  }
}
