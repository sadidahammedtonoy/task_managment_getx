import 'package:flutter/material.dart';
import '../Auth/View/signup_signin/setpassword.dart';
import '../Auth/View/signup_signin/signin.dart';
import '../Auth/View/signup_signin/signup.dart';
import '../Auth/View/varification/varification_email.dart';
import '../Auth/View/varification/varification_pin.dart';
import '../Features/Task_managment/View/addTask.dart';
import '../Features/Task_managment/View/updateProfile.dart';
import '../Features/Task_managment/View/viewTask.dart';
import '../Features/appbar_navbar/navbar.dart';
import '../Splash/View/SpalashScreen.dart';



class AppRoutes {
  static final Map<String, Widget Function(BuildContext)> routes = {
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
  };
}