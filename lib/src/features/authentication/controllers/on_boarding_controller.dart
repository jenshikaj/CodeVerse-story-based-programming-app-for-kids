import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_swipe/PageHelpers/LiquidController.dart';
import '../../../constants/colors.dart';
import '../../../constants/image_strings.dart';
import '../../../constants/text_strings.dart';
import '../models/model_on_boarding.dart';
import '../screens/on_boarding/on_boarding_page_widget.dart';
import '../screens/welcome/welcome_screen.dart';

class OnBoardingController extends GetxController {
  final LiquidController controller = LiquidController();
  RxInt currentPage = 0.obs;
  late List<OnBoardingPageWidget> pages;

  OnBoardingController(Size size) {
    pages = [
      OnBoardingPageWidget(
        model: OnBoardingModel(
          image: CVOnBoardingImage1,
          title: CVOnBoardingTitle1,
          subTitle: CVOnBoardingSubTitle1,
          counterText: CVOnBoardingCounter1,
          height: size.height,
          bgColor: CVBackgroundColor,
        ),
      ),
      OnBoardingPageWidget(
        model: OnBoardingModel(
          image: CVOnBoardingImage2,
          title: CVOnBoardingTitle2,
          subTitle: CVOnBoardingSubTitle2,
          counterText: CVOnBoardingCounter2,
          height: size.height,
          bgColor: CVBackgroundColor,
        ),
      ),
      OnBoardingPageWidget(
        model: OnBoardingModel(
          image: CVOnBoardingImage3,
          title: CVOnBoardingTitle3,
          subTitle: CVOnBoardingSubTitle3,
          counterText: CVOnBoardingCounter3,
          height: size.height,
          bgColor: CVBackgroundColor,
        ),
      )
    ];
  }

  animateToNextSlide() {
    int nextPage = controller.currentPage + 1;
    if (nextPage < pages.length) {
      controller.animateToPage(page: nextPage);
    } else {
      Get.to(
        () => const WelcomeScreen(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 800),
      );
    }
  }

  skip() {
    Get.to(
      () => const WelcomeScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 800),
    );
  }

  onPageChangedCallback(int activePageIndex) {
    currentPage.value = activePageIndex;
  }
}
