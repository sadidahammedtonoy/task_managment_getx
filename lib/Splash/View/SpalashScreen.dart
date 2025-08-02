import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../Auth/View/signup_signin/signin.dart';
import '../../Const/assets.dart';
import '../../Auth/Controller/controller.dart';
import '../../Features/appbar_navbar/navbar.dart';
import '../../Features/Background/Background.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    moveToNextScreen();
  }

  Future<void> moveToNextScreen() async {
    await Future.delayed(Duration(seconds: 2));
    bool isLoggedIn = await AuthController.isUserLoggedIn();
    if (isLoggedIn) {
      Get.offNamed(navbar.name);
    } else {
      Get.offNamed(signin.name);
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const String name = '/';

  @override
  Widget build(BuildContext context) {
    Get.put(SplashScreenController());
    return Scaffold(
      body: background(
        child: Center(child: SvgPicture.asset(AssetPaths.logoSvg)),
      ),
    );
  }
}