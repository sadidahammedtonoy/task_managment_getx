import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/Auth/Model/authModel.dart';
import 'dart:convert';

class AuthController extends GetxController {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  var userModel = Rxn<UserModel>();
  var accessToken = Rxn<String>();

  static const String _userDataKey = 'user_data';
  static const String _tokenKey = 'token';

  Future<void> saveUserData(UserModel model, String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    await sharedPreferences.setString(_userDataKey, jsonEncode(model.toJson()));
    await sharedPreferences.setString(_tokenKey, token);

    userModel.value = model;
    accessToken.value = token;
  }

  Future<void> updateUserData(UserModel model) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_userDataKey, jsonEncode(model.toJson()));
    userModel.value = model;
  }

  Future<void> getUserData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userData = sharedPreferences.getString(_userDataKey);
    if (userData != null) {
      userModel.value = UserModel.fromJson(jsonDecode(userData));
    }
    accessToken.value = sharedPreferences.getString(_tokenKey);
  }

  Future<bool> isUserLoggedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString(_tokenKey);

    if (token != null) {
      await getUserData();
      return true;
    } else {
      return false;
    }
  }

  Future<void> clearUserData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    userModel.value = null;
    accessToken.value = null;
  }
}