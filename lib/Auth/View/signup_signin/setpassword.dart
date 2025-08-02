import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/Auth/Model/varificationModel.dart';
import 'package:task_manager/Auth/View/signup_signin/signin.dart';
import 'package:task_manager/Features/Global%20Widgets/progressIndicator.dart';
import '../../../Network/network.dart';
import '../../../Features/Background/Background.dart';
import '../../../Features/Global Widgets/snackbar.dart';
import '../../../Const/urls.dart';

class SetpasswordController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  var resetPasswordInProgress = false.obs;
  var obscurePassword = true.obs;
  var confirmObscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    confirmObscurePassword.value = !confirmObscurePassword.value;
  }

  void onTapSignInButton() {
    Get.offAllNamed(signin.name);
  }

  Future<void> resetPassword() async {
    resetPasswordInProgress.value = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> requestBody = {
      "email": prefs.getString('email') ?? '',
      "OTP": prefs.getString('UserOtp') ?? '',
      "password": confirmPasswordController.text,
    };
    NetworkResponse response = await Get.find<NetworkCaller>().postRequest(
      url: urls.ResetPasswordUrl,
      body: requestBody,
      isFromLogin: false,
    );

    if (response.isSuccess) {
      VerificationDataModel passwordResetVerificationDataModel =
      VerificationDataModel.fromJson(response.body!);

      String getStatus = passwordResetVerificationDataModel.status ?? '';
      String getData = passwordResetVerificationDataModel.data ?? '';

      if (getStatus == 'success') {
        passwordController.clear();
        confirmPasswordController.clear();
        showSnackBarMessage(Get.context!, "$getStatus $getData");
        showSnackBarMessage(Get.context!, 'Please Sign In With New Password');
        await Future.delayed(Duration(seconds: 1));
        Get.offAllNamed(signin.name);
      } else {
        showSnackBarMessage(Get.context!, "$getStatus $getData");
      }
    } else {
      showSnackBarMessage(Get.context!, response.errorMessage!);
    }

    resetPasswordInProgress.value = false;
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

class Setpassword extends StatelessWidget {
  const Setpassword({super.key});

  static const String name = '/setpassword';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SetpasswordController());
    return Scaffold(
      body: background(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: controller.formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  Text(
                    'Set Password',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Minimum Length password 8 characters with Latter and number combination',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  Obx(() => TextFormField(
                    controller: controller.passwordController,
                    obscureText: controller.obscurePassword.value,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  )),
                  const SizedBox(height: 8),
                  Obx(() => TextFormField(
                    controller: controller.confirmPasswordController,
                    obscureText: controller.confirmObscurePassword.value,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.confirmObscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      } else if (controller.passwordController.text !=
                          controller.confirmPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  )),
                  const SizedBox(height: 16),
                  Obx(() => Visibility(
                    visible: !controller.resetPasswordInProgress.value,
                    replacement: CenteredCircularProgressIndicator(),
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.formKey.currentState!.validate()) {
                          controller.resetPassword();
                        }
                      },
                      child: Text('Confirm'),
                    ),
                  )),
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'have an account? ',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = controller.onTapSignInButton,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}