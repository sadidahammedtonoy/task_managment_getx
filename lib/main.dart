import 'package:flutter/material.dart';
import 'package:task_manager/Features/Task_managment/View/addTask.dart';
import 'package:task_manager/Auth/View/varification/varification_pin.dart';
import 'package:task_manager/Auth/View/signup_signin/setpassword.dart';
import 'package:task_manager/Auth/View/signup_signin/signup.dart';
import 'package:task_manager/Auth/View/signup_signin/signin.dart';
import 'package:task_manager/Features/Task_managment/View/updateProfile.dart';
import 'package:task_manager/Features/appbar_navbar/navbar.dart';
import 'package:task_manager/Features/Task_managment/View/viewTask.dart';
import 'Auth/View/varification/varification_email.dart';
import 'Const/theme.dart';
import 'Splash/View/SpalashScreen.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
  static GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();

}
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: MyApp.navigator,
      theme: CustomTheme.customTheme,
      initialRoute: '/',
      routes: {
        SplashScreen.name: (context) => SplashScreen(),
        signin.name: (context) => signin(),
        signup.name: (context) => signup(),
        Emailvarification.name: (context) => Emailvarification(),
        pinVarification.name: (context) => pinVarification(),
        Setpassword.name: (context) => Setpassword(),
        navbar.name: (context) => navbar(),
        profileUpdate.name: (context) => profileUpdate(),
        taskView.name: (context) => taskView(),
        addTask.name: (context) => addTask(),
      },
    );
  }
}

