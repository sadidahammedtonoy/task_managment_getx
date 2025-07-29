import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Auth/View/signup_signin/signin.dart';
import '../../Const/assets.dart';
import '../../Auth/Controller/controller.dart';
import '../../Features/appbar_navbar/navbar.dart';
import '../../Features/Background/Background.dart';

class SpalashScreen extends StatefulWidget {
  const SpalashScreen({super.key});

  static const String name = '/';

  @override
  State<SpalashScreen> createState() => _SpalashScreenState();
}

class _SpalashScreenState extends State<SpalashScreen> {
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveToNextScreen();
    });
  }

  Future<void> _moveToNextScreen() async {
    await Future.delayed(Duration(seconds: 2));
    bool isLoggedIn = await AuthController.isUserLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, navbar.name);
    } else {
      Navigator.pushReplacementNamed(context, signin.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: background(
        child: Center(child: SvgPicture.asset(AssetPaths.logoSvg)),
      ),
    );
  }
}
