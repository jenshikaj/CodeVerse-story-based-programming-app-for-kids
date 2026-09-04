import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:codeverse/src/constants/colors.dart';
import 'package:codeverse/src/constants/image_strings.dart';
import 'package:codeverse/src/features/authentication/controllers/splash_screen_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final SplashScreenController splashController;

  /// Brand palette for the drifting background icons.
  static const _iconTints = <Color>[
    CVAccentColor,
    CVAccentColor2,
    CVAccentColor3,
  ];

  @override
  void initState() {
    super.initState();
    splashController = Get.isRegistered<SplashScreenController>()
        ? Get.find<SplashScreenController>()
        : Get.put(SplashScreenController());

    splashController.startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CVBackgroundColor,
      body: Stack(
        children: [
          // --- top icons: drift downwards and inwards ---
          _buildAnimatedIcon(CVSplashTopIcon1,
              top: 60, offset: -10, angle: 2.4, tint: 0),
          _buildAnimatedIcon(CVSplashTopIcon2,
              top: -5, offset: 60, angle: -0.3, tint: 1),
          _buildAnimatedIcon(CVSplashTopIcon3,
              top: 50, offset: 50, angle: 0.5, isRight: true, tint: 2),
          _buildAnimatedIcon(CVSplashTopIcon4,
              top: -10, offset: 100, angle: -0.3, isRight: true, tint: 0),
          _buildAnimatedIcon(CVSplashTopIcon5,
              top: 10, offset: -10, angle: 0.5, isRight: true, tint: 1),
          _buildAnimatedIcon(CVSplashTopIcon6,
              top: 30, offset: 130, angle: -0.4, tint: 2),

          // --- bottom icons: mirror the top, drifting upwards and inwards ---
          _buildAnimatedIcon(CVSplashTopIcon4,
              bottom: 60, offset: -10, angle: -0.4, tint: 2),
          _buildAnimatedIcon(CVSplashTopIcon5,
              bottom: -5, offset: 60, angle: 0.4, tint: 0),
          _buildAnimatedIcon(CVSplashTopIcon6,
              bottom: 50, offset: 50, angle: -0.6, isRight: true, tint: 1),
          _buildAnimatedIcon(CVSplashTopIcon1,
              bottom: -10, offset: 100, angle: 0.9, isRight: true, tint: 2),
          _buildAnimatedIcon(CVSplashTopIcon2,
              bottom: 10, offset: -10, angle: -0.5, isRight: true, tint: 0),
          _buildAnimatedIcon(CVSplashTopIcon3,
              bottom: 30, offset: 130, angle: 0.7, tint: 1),

          // --- app logo, zooming in ---
          Center(
            child: Obx(
              () => AnimatedScale(
                duration: const Duration(milliseconds: 2000),
                scale: splashController.animate.value ? 1.0 : 0.05,
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 1600),
                  opacity: splashController.animate.value ? 1 : 0,
                  child: const Image(image: AssetImage(CVSplashImage)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Positions one drifting background icon.
  Widget _buildAnimatedIcon(
    String asset, {
    double? top,
    double? bottom,
    required double offset,
    required double angle,
    required int tint,
    bool isRight = false,
  }) {
    assert(
      (top == null) != (bottom == null),
      'Provide exactly one of top or bottom.',
    );

    return Obx(() {
      final animate = splashController.animate.value;
      final horizontal = animate ? offset + 30 : offset;

      return AnimatedPositioned(
        duration: const Duration(milliseconds: 1600),
        curve: Curves.easeOut,
        top: top == null ? null : (animate ? top + 30 : top),
        bottom: bottom == null ? null : (animate ? bottom + 30 : bottom),
        left: isRight ? null : horizontal,
        right: isRight ? horizontal : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 1600),
          opacity: animate ? 0.75 : 0.0,
          child: Transform.rotate(
            angle: angle,
            child: Image(
              image: AssetImage(asset),
              color: _iconTints[tint % _iconTints.length],
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ),
      );
    });
  }
}
