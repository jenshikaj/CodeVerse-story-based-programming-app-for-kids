import 'package:codeverse/src/features/core/screens/dashboard/dashboard_screen.dart';
import 'package:codeverse/src/repository/authentication_repository/authentication_repository.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  static OtpController get instance => Get.find();

  var verificationId = ''.obs;

  void setVerificationId(String id) {
    verificationId.value = id;
  }

  Future<void> verifyOTP(String otp) async {
    var isVerified = await AuthenticationRepository.instance
        .verifyOTP(otp, verificationId.value);
    isVerified ? Get.offAll(const DashboardScreen()) : Get.back();
  }
}
