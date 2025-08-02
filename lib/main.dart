import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Const/theme.dart';
import 'Routes/AppRoute.dart';

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
      routes: AppRoutes.routes,
    );
  }
}