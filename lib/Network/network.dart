import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:task_manager/Auth/Controller/controller.dart';
import 'package:task_manager/Auth/View/signup_signin/signin.dart';

class NetworkResponse {
  final bool isSuccess;
  final int statusCode;
  final Map<String, dynamic>? body;
  final String? errorMessage;

  NetworkResponse({
    required this.isSuccess,
    required this.statusCode,
    this.body,
    this.errorMessage,
  });
}

class NetworkCaller extends GetxController {
  static final NetworkCaller _instance = NetworkCaller._internal();
  factory NetworkCaller() => _instance;
  NetworkCaller._internal();

  static const String _defaultErrorMessage = 'Something went wrong';
  static const String _unAuthorizeMessage = 'Un-authorized token';

  Future<NetworkResponse> getRequest({required String url}) async {
    try {
      Uri uri = Uri.parse(url);
      final Map<String, String> header = {
        'content-type': 'application/json',
        'token': Get.find<AuthController>().accessToken.value ?? '',
      };

      _logRequest(url, null, header);
      http.Response response = await http.get(uri, headers: header);
      print(response.statusCode);
      _logResponse(url, response);

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decodedJson,
        );
      } else if (response.statusCode == 401) {
        await _onUnAuthorize();
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: _unAuthorizeMessage,
        );
      } else {
        final decodedJson = jsonDecode(response.body);
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: decodedJson['data'] ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  Future<NetworkResponse> postRequest({
    required String url,
    Map<String, String>? body,
    bool isFromLogin = false,
  }) async {
    try {
      Uri uri = Uri.parse(url);

      final Map<String, String> headers = {
        'content-type': 'application/json',
        'token': Get.find<AuthController>().accessToken.value ?? '',
      };

      _logRequest(url, body, headers);
      http.Response response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      _logResponse(url, response);

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decodedJson,
        );
      } else if (response.statusCode == 401) {
        if (isFromLogin == false) {
          await _onUnAuthorize();
        }
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: _unAuthorizeMessage,
        );
      } else {
        final decodedJson = jsonDecode(response.body);
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: decodedJson['data'] ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  void _logRequest(
      String url,
      Map<String, String>? body,
      Map<String, String>? headers,
      ) {
    debugPrint(
      '================== REQUEST ========================\n'
          'URL: $url\n'
          'HEADERS: $headers\n'
          'BODY: $body\n'
          '=============================================',
    );
  }

  void _logResponse(String url, http.Response response) {
    debugPrint(
      '=================== RESPONSE =======================\n'
          'URL: $url\n'
          'STATUS CODE: ${response.statusCode}\n'
          'BODY: ${response.body}\n'
          '=============================================',
    );
  }

  Future<void> _onUnAuthorize() async {
    await Get.find<AuthController>().clearUserData();
    Get.offAllNamed(signin.name);
  }
}