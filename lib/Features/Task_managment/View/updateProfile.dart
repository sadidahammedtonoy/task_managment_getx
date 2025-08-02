import 'dart:convert';
import 'dart:typed_data';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_manager/Auth/Model/authModel.dart';
import '../../../Const/urls.dart';
import '../../../Auth/Controller/controller.dart';
import '../../../Network/network.dart';
import '../../Global Widgets/progressIndicator.dart';
import '../../Background/Background.dart';
import '../../Global Widgets/snackbar.dart';
import '../../appbar_navbar/appbar.dart';

class ProfileUpdateController extends GetxController {
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController firstNameTEController = TextEditingController();
  final TextEditingController lastNameTEController = TextEditingController();
  final TextEditingController phoneTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  var selectedImage = Rxn<XFile>();
  var updateProfileInProgress = false.obs;
  var obscurePassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    emailTEController.text = AuthController().userModel.value?.email ?? '';
    firstNameTEController.text = AuthController().userModel.value?.firstName ?? '';
    lastNameTEController.text = AuthController().userModel.value?.lastName ?? '';
    phoneTEController.text = AuthController().userModel.value?.mobile ?? '';
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> onTapPhotoPicker() async {
    final XFile? pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      final int fileSizeInBytes = await pickedImage.length();
      final double fileSizeInKB = fileSizeInBytes / 1024;

      if (fileSizeInKB > 64) {
        showSnackBarMessage(
          Get.context!,
          'Image is too large. Max allowed size is 64KB.',
        );
      } else {
        selectedImage.value = pickedImage;
      }
    } else {
      showSnackBarMessage(Get.context!, 'No image selected');
    }
  }

  void onTapSubmitButton() {
    if (formKey.currentState!.validate()) {
      updateProfile();
    }
  }

  Future<void> updateProfile() async {
    updateProfileInProgress.value = true;

    Uint8List? imageBytes;

    Map<String, String> requestBody = {
      'email': emailTEController.text.trim(),
      'firstName': firstNameTEController.text.trim(),
      'lastName': lastNameTEController.text.trim(),
      'mobile': phoneTEController.text.trim(),
    };

    if (passwordTEController.text.isNotEmpty) {
      requestBody['password'] = passwordTEController.text;
    }
    if (selectedImage.value != null) {
      imageBytes = await selectedImage.value!.readAsBytes();
      requestBody['photo'] = base64Encode(imageBytes);
    }

    NetworkResponse response = await Get.find<NetworkCaller>().postRequest(
      url: urls.UpdateProfileUrl,
      body: requestBody,
    );

    updateProfileInProgress.value = false;

    if (response.isSuccess) {
      UserModel userModel = UserModel(
        id: AuthController().userModel.value!.id,
        email: emailTEController.text.trim(),
        firstName: firstNameTEController.text.trim(),
        lastName: lastNameTEController.text.trim(),
        mobile: phoneTEController.text.trim(),
        photo: imageBytes == null
            ? AuthController().userModel.value!.photo
            : base64Encode(imageBytes),
      );
      await AuthController().updateUserData(userModel);

      passwordTEController.clear();
      showSnackBarMessage(Get.context!, 'Profile updated');
    } else {
      showSnackBarMessage(Get.context!, response.errorMessage!);
    }
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

class profileUpdate extends StatelessWidget {
  const profileUpdate({super.key});

  static const String name = '/update-profile';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileUpdateController());
    return Scaffold(
      appBar: appbar(),
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
                  const SizedBox(height: 40),
                  Text(
                    'Update Profile',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  _buildPhotoPicker(controller),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
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
                      int length = value?.length ?? 0;
                      if (length > 0 && length <= 6) {
                        return 'Enter a password more than 6 letters';
                      }
                      return null;
                    },
                  )),
                  const SizedBox(height: 16),
                  Obx(() => Visibility(
                    visible: !controller.updateProfileInProgress.value,
                    replacement: CenteredCircularProgressIndicator(),
                    child: ElevatedButton(
                      onPressed: controller.onTapSubmitButton,
                      child: Icon(Icons.arrow_circle_right_outlined),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker(ProfileUpdateController controller) {
    return GestureDetector(
      onTap: controller.onTapPhotoPicker,
      child: Container(
        height: 50,
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Photo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => Text(
              controller.selectedImage.value == null
                  ? 'Select image'
                  : controller.selectedImage.value!.name,
              maxLines: 1,
              style: TextStyle(overflow: TextOverflow.ellipsis),
            )),
          ],
        ),
      ),
    );
  }
}