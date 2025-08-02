import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/Network/network.dart';
import 'package:task_manager/Auth/View/signup_signin/signin.dart';
import '../../../Const/urls.dart';
import 'package:task_manager/Features/Background/Background.dart';
import '../../../Features/Global Widgets/progressIndicator.dart';
import '../../../Features/Global Widgets/snackbar.dart';

class SignupController extends GetxController {
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController firstNameTEController = TextEditingController();
  final TextEditingController lastNameTEController = TextEditingController();
  final TextEditingController phoneTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var signUpInProgress = false.obs;
  var obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void onTapSignUpButton() {
    if (formKey.currentState!.validate()) {
      signUp();
    }
  }

  void onTapSignInButton() {
    Get.back();
  }

  Future<void> signUp() async {
    signUpInProgress.value = true;

    Map<String, String> requestBody = {
      "email": emailTEController.text.trim(),
      "firstName": firstNameTEController.text.trim(),
      "lastName": lastNameTEController.text.trim(),
      "mobile": phoneTEController.text.trim(),
      "password": passwordTEController.text,
    };

    NetworkResponse response = await networkCaller.postRequest(
      url: urls.SignupUrl,
      body: requestBody,
    );

    signUpInProgress.value = false;

    if (response.isSuccess) {
      clearTextFields();
      showSnackBarMessage(
        Get.context!,
        'Registration has been success. Please login',
      );
      Get.offAllNamed(signin.name);
    } else {
      showSnackBarMessage(Get.context!, response.errorMessage!);
    }
  }

  void clearTextFields() {
    emailTEController.clear();
    firstNameTEController.clear();
    lastNameTEController.clear();
    phoneTEController.clear();
    passwordTEController.clear();
  }

  @override
  void onClose() {
    emailTEController.dispose();
    firstNameTEController.dispose();
    lastNameTEController.dispose();
    phoneTEController.dispose();
    passwordTEController.dispose();
    super.onClose();
  }
}

class signup extends StatelessWidget {
  const signup({super.key});

  static const String name = '/sign-up';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    return Scaffold(
      body: background(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: controller.formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  Text(
                    'Join With Us',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: controller.emailTEController,
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
                  TextFormField(
                    controller: controller.firstNameTEController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(hintText: 'First name'),
                    validator: (String? value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.lastNameTEController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(hintText: 'Last name'),
                    validator: (String? value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Enter your Last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.phoneTEController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(hintText: 'Mobile'),
                    validator: (String? value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Enter your mobile number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Obx(() => TextFormField(
                    controller: controller.passwordTEController,
                    obscureText: controller.obscurePassword.value,
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
                    visible: !controller.signUpInProgress.value,
                    replacement: CenteredCircularProgressIndicator(),
                    child: ElevatedButton(
                      onPressed: controller.onTapSignUpButton,
                      child: Icon(Icons.arrow_circle_right_outlined),
                    ),
                  )),
                  const SizedBox(height: 32),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Have an account? ",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
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