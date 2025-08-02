import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/Auth/View/signup_signin/setpassword.dart';
import 'package:task_manager/Auth/View/signup_signin/signin.dart';
import 'package:task_manager/Features/Global%20Widgets/progressIndicator.dart';
import '../../../Const/urls.dart';
import '../../Model/varificationModel.dart';
import '../../../Network/network.dart';
import '../../../Features/Background/Background.dart';
import '../../../Features/Global Widgets/snackbar.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinVarificationController extends GetxController {
  final TextEditingController otpTEController = TextEditingController();
  final NetworkCaller Netcontroller = Get.put(NetworkCaller());

  final GlobalKey<FormState> key = GlobalKey<FormState>();
  var otpisLoading = false.obs;

  void onTapSignInButton() {
    Get.offAllNamed(signin.name);
  }

  Future<void> otpVerification() async {
    otpisLoading.value = true;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? email = sharedPreferences.getString('email') ?? '';
    await sharedPreferences.setString('UserOtp', otpTEController.text.trim());

    NetworkResponse response = await Netcontroller.getRequest(
      url: urls.VeriftOtpdUrl(email, otpTEController.text.trim()),
    );
    if (response.isSuccess) {
      VerificationDataModel emailPinVerificationDataModel =
      VerificationDataModel.fromJson(response.body!);

      String getStatus = emailPinVerificationDataModel.status ?? '';
      String getData = emailPinVerificationDataModel.data ?? '';

      if (getStatus == 'success') {
        otpisLoading.value = false;
        otpTEController.clear();
        showSnackBarMessage(Get.context!, "$getStatus $getData");
        showSnackBarMessage(Get.context!, 'Please set your new password');
        await Future.delayed(Duration(seconds: 1));
        Get.offAllNamed(Setpassword.name);
      } else {
        otpisLoading.value = false;
        showSnackBarMessage(Get.context!, "$getStatus $getData");
      }
    } else {
      otpisLoading.value = false;
      showSnackBarMessage(Get.context!, response.errorMessage!);
    }

    otpisLoading.value = false;
  }

  @override
  void onClose() {
    otpTEController.dispose();
    super.onClose();
  }
}

class pinVarification extends StatelessWidget {
  const pinVarification({super.key});

  static const String name = '/emailpinvarification';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PinVarificationController());
    return Scaffold(
      body: background(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: controller.key,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  Text(
                    'Pin Verification',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A 6 digits OTP has been sent to your email address',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  PinCodeTextField(
                    length: 6,
                    animationType: AnimationType.fade,
                    keyboardType: TextInputType.number,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 50,
                      fieldWidth: 50,
                      activeFillColor: Colors.white,
                      selectedColor: Colors.green,
                      inactiveColor: Colors.grey,
                    ),
                    animationDuration: Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    controller: controller.otpTEController,
                    appContext: context,
                  ),
                  const SizedBox(height: 16),
                  Obx(() => Visibility(
                    visible: !controller.otpisLoading.value,
                    replacement: CenteredCircularProgressIndicator(),
                    child: ElevatedButton(
                      onPressed: controller.otpVerification,
                      child: Text('Verify'),
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