import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/Auth/Controller/controller.dart';
import 'package:task_manager/Auth/View/signup_signin/signin.dart';
import 'package:task_manager/Features/Task_managment/View/updateProfile.dart';
import '../Global Widgets/snackbar.dart';

class AppbarController extends GetxController {
  void onTapLogOutButton() async {
    AuthController controller = Get.find<AuthController>();
    await controller.clearUserData();
    Get.offAllNamed(signin.name);
  }

  void onTapProfileBar() {
    final currentRoute = Get.currentRoute;

    if (currentRoute == profileUpdate.name) {
      showSnackBarMessage(Get.context!, 'You are already on the profile page');
    } else {
      Get.toNamed(profileUpdate.name);
    }
  }
}

class appbar extends StatelessWidget implements PreferredSizeWidget {
  const appbar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppbarController());
    final authController = Get.find<AuthController>();

    return AppBar(
      backgroundColor: Colors.blue,
      title: GestureDetector(
        onTap: controller.onTapProfileBar,
        child: Row(
          children: [
            Obx(() => CircleAvatar(
              backgroundImage: authController.userModel.value?.photo == null
                  ? null
                  : MemoryImage(
                base64Decode(authController.userModel.value!.photo!),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authController.userModel.value?.Fullname ?? '',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    authController.userModel.value?.email ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              )),
            ),
            IconButton(
              onPressed: controller.onTapLogOutButton,
              icon: Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }
}