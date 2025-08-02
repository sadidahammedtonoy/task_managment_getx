import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/Auth/Controller/controller.dart';
import 'package:task_manager/Auth/Model/authModel.dart';
import 'package:task_manager/Features/appbar_navbar/navbar.dart';
import 'package:task_manager/Features/Background/Background.dart';
import 'package:email_validator/email_validator.dart';
import '../../../Network/network.dart';
import '../../../Features/Global Widgets/progressIndicator.dart';
import '../../../Features/Global Widgets/snackbar.dart';
import '../../../Const/urls.dart';
import '../varification/varification_email.dart';
import 'signup.dart';

class SigninController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var signInProgress = false.obs;
  var obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void onTapSignInButton() {
    if (formKey.currentState!.validate()) {
      signIn();
    }
  }

  void onTapForgetPassword() {
    Get.toNamed(Emailvarification.name);
  }

  void onTapSignUpButton() {
    Get.toNamed(signup.name);
  }

  Future<void> signIn() async {
    signInProgress.value = true;

    Map<String, String> requestBody = {
      "email": emailController.text.trim(),
      "password": passwordController.text,
    };
    NetworkResponse response = await networkCaller.postRequest(
      url: urls.LoginUrl,
      body: requestBody,
      isFromLogin: true,
    );

    if (response.isSuccess) {
      UserModel userModel = UserModel.fromJson(response.body!['data']);
      String token = response.body!['token'];

      await AuthController.saveUserData(userModel, token);
      Get.offAllNamed(navbar.name);
    } else {
      showSnackBarMessage(Get.context!, response.errorMessage!);
    }

    signInProgress.value = false;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class signin extends StatelessWidget {
  const signin({super.key});

  static const String name = '/sign-in';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SigninController());
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
                    'Get Started With',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: controller.emailController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(hintText: 'Email'),
                    validator: (String? value) {
                      String email = value ?? '';
                      if (EmailValidator.validate(email) == false) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Obx(() => TextFormField(
                    controller: controller.passwordController,
                    obscureText: controller.obscurePassword.value,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Password',
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
                      if ((value?.length ?? 0) <= 6) {
                        return 'Enter a valid password';
                      }
                      return null;
                    },
                  )),
                  const SizedBox(height: 16),
                  Obx(() => Visibility(
                    visible: !controller.signInProgress.value,
                    replacement: CenteredCircularProgressIndicator(),
                    child: ElevatedButton(
                      onPressed: controller.onTapSignInButton,
                      child: Icon(Icons.arrow_circle_right_outlined),
                    ),
                  )),
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: controller.onTapForgetPassword,
                          child: Text(
                            'Forget Password?',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Don\'t have an account? ',
                            style: TextStyle(
                              color: Colors.black,
                              letterSpacing: 0.4,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = controller.onTapSignUpButton,
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