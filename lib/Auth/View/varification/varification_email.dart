import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/Auth/View/varification/varification_pin.dart';
import 'package:task_manager/Features/Global%20Widgets/progressIndicator.dart';
import '../../../Const/urls.dart';
import '../../Model/varificationModel.dart';
import '../../../Network/network.dart';
import '../../../Features/Background/Background.dart';
import '../../../Features/Global Widgets/snackbar.dart';
import '../signup_signin/signin.dart';

class EmailvarificationController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  var emailisLoading = false.obs;

  void onTapSignInButton() {
    Get.offAllNamed(signin.name);
  }

  Future<void> getOtpMail() async {
    emailisLoading.value = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token') ?? '';

    NetworkResponse response = await networkCaller.getRequest(
      url: urls.RecoverVerifyEmailUrl(emailController.text.trim()),
    );
    if (response.isSuccess) {
      VerificationDataModel emailVerificationDataModel =
      VerificationDataModel.fromJson(response.body!);

      String getStatus = emailVerificationDataModel.status ?? '';
      String getData = emailVerificationDataModel.data ?? '';

      if (getStatus == 'success') {
        emailisLoading.value = false;
        SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
        sharedPreferences.setString('email', emailController.text.trim());
        emailController.clear();
        showSnackBarMessage(Get.context!, "$getStatus $getData");
        await Future.delayed(Duration(seconds: 1));
        Get.offAllNamed(pinVarification.name);
      } else {
        emailisLoading.value = false;
        showSnackBarMessage(Get.context!, "$getStatus $getData");
      }
    } else {
      emailisLoading.value = false;
      showSnackBarMessage(Get.context!, response.errorMessage!);
    }

    emailisLoading.value = false;
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}

class Emailvarification extends StatelessWidget {
  const Emailvarification({super.key});

  static const String name = '/emailvarification';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmailvarificationController());
    return Scaffold(
      body: background(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Form(
              key: controller.key,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  Text(
                    'Your Email Address',
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'A 6 digit varification pin will sent to your\nemail address',
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: controller.emailController,
                    decoration: InputDecoration(hintText: 'Email'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!EmailValidator.validate(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Obx(() => Visibility(
                          visible: !controller.emailisLoading.value,
                          replacement: CenteredCircularProgressIndicator(),
                          child: ElevatedButton(
                            onPressed: () {
                              if (controller.key.currentState!.validate()) {
                                controller.getOtpMail();
                              }
                            },
                            child: Icon(Icons.arrow_circle_right_outlined),
                          ),
                        )),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            text: 'Have account? ',
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