import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:task_manager/Auth/Controller/controller.dart';
import 'package:task_manager/Auth/View/signup_signin/signin.dart';
import 'package:task_manager/Features/Task_managment/View/updateProfile.dart';

import '../Global Widgets/snackbar.dart';

class appbar extends StatefulWidget implements PreferredSizeWidget {
  const appbar({super.key});

  @override
  State<appbar> createState() => _appbarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _appbarState extends State<appbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,

      title: GestureDetector(
        onTap: () => _onTapProfileBar(context),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage:
              AuthController.userModel?.photo == null
                  ? null
                  : MemoryImage(
                base64Decode(AuthController.userModel!.photo!),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AuthController.userModel!.Fullname,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    AuthController.userModel!.email,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
            IconButton(onPressed: _onTapLogOutButton, icon: Icon(Icons.logout)),
          ],
        ),
      ),
    );
  }

  Future<void> _onTapLogOutButton() async {
    await AuthController.clearUserData();

    Navigator.pushNamedAndRemoveUntil(
      context,
      signin.name,
      (predicate) => false,
    );
  }

  void _onTapProfileBar(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute == profileUpdate.name) {
      showSnackBarMessage(context, 'You are already on the profile page');
    } else {
      // Navigate to profile page
      Navigator.pushNamed(context, profileUpdate.name);
    }
  }
}
