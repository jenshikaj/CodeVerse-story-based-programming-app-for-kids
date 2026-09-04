import 'package:codeverse/firebase_options.dart';
import 'package:codeverse/src/features/authentication/controllers/login_controller.dart';
import 'package:codeverse/src/repository/authentication_repository/authentication_repository.dart';
import 'package:codeverse/src/repository/user_repository/user_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'src/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((FirebaseApp value) {
    Get.put(AuthenticationRepository());
    Get.put(UserRepository()); // Initialize UserRepository
  });

  await GetStorage.init();

  Get.put(LoginController(), permanent: true);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      theme: CVAppTheme.lightTheme,
      darkTheme: CVAppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
