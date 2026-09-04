import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

/// Consistent app-wide notifications.

class CVNotify {
  CVNotify._();

  static void success(String message, {String title = 'Success'}) {
    _show(
      title: title,
      message: message,
      background: const Color(0xFF2E7D32),
      icon: Icons.check_circle_outline,
    );
  }

  static void error(String message, {String title = 'Something went wrong'}) {
    _show(
      title: title,
      message: message,
      background: const Color(0xFFC62828),
      icon: Icons.error_outline,
      duration: const Duration(seconds: 5),
    );
  }

  static void info(String message, {String title = 'Notice'}) {
    _show(
      title: title,
      message: message,
      background: const Color(0xFF1565C0),
      icon: Icons.info_outline,
    );
  }

  static void warning(String message, {String title = 'Please check'}) {
    _show(
      title: title,
      message: message,
      background: const Color(0xFFEF6C00),
      icon: Icons.warning_amber_outlined,
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color background,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    debugPrint('[$title] $message');

    void present() {
      try {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: background,
          colorText: Colors.white,
          icon: Icon(icon, color: Colors.white),
          margin: const EdgeInsets.all(12),
          borderRadius: 10,
          duration: duration,
          isDismissible: true,
        );
      } catch (e) {
        debugPrint('Could not display notification: $e');
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => present());
  }
}
