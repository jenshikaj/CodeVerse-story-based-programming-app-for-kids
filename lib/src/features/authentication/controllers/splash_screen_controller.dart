import 'package:codeverse/src/features/authentication/screens/welcome/welcome_screen.dart';
import 'package:codeverse/src/features/core/screens/dashboard/dashboard_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/on_boarding/on_boarding_screen.dart';

class SplashScreenController extends GetxController {
  static SplashScreenController get find => Get.find();

  RxBool animate = false.obs;
  RxBool hasTransitioned = false.obs;

  Future startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    animate.value = true;
    await Future.delayed(const Duration(milliseconds: 5000));
    await checkUserStatus();
  }

  Future<void> checkUserStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if it's the first time the app is launched
    bool isFirstTimeUser = prefs.getBool('isFirstTimeUser') ?? true;

    // Check if the user is logged in
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isFirstTimeUser) {
      // Set isFirstTimeUser to false
      await prefs.setBool('isFirstTimeUser', false);

      if (!hasTransitioned.value) {
        hasTransitioned.value = true;
        Get.to(() => const OnBoardingScreen(),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 800));
      }
    } else {
      // Check if user is logged in
      if (isLoggedIn) {
        if (!hasTransitioned.value) {
          hasTransitioned.value = true;
          Get.to(() => const DashboardScreen(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 800));
        }
      } else {
        if (!hasTransitioned.value) {
          hasTransitioned.value = true;
          Get.to(() => const WelcomeScreen(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 800));
        }
      }
    }
  }
}
