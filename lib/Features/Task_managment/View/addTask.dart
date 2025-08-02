import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/Network/network.dart';
import 'package:task_manager/Features/Global%20Widgets/progressIndicator.dart';
import 'package:task_manager/Features/Global%20Widgets/snackbar.dart';
import '../../../Const/urls.dart';
import '../../Background/Background.dart';
import '../../appbar_navbar/appbar.dart';
import '../../appbar_navbar/navbar.dart';
final NetworkCaller conroller = Get.put(NetworkCaller());
class AddTaskController extends GetxController {
  final TextEditingController titleTEController = TextEditingController();
  final TextEditingController descriptionTEController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var addNewTaskInProgress = false.obs;

  void onTapSubmitButton() {
    if (formKey.currentState!.validate()) {
      addNewTask();
    }
  }

  Future<void> addNewTask() async {
    addNewTaskInProgress.value = true;

    Map<String, String> requestBody = {
      'title': titleTEController.text.trim(),
      'description': descriptionTEController.text.trim(),
      'status': 'New',
    };

    NetworkResponse response = await conroller.postRequest(
      url: urls.AddNewTaskUrl,
      body: requestBody,
    );

    addNewTaskInProgress.value = false;

    if (response.isSuccess) {
      titleTEController.clear();
      descriptionTEController.clear();
      showSnackBarMessage(Get.context!, 'Task added successfully');
      Get.offNamed(navbar.name);
    } else {
      showSnackBarMessage(
        Get.context!,
        'Failed to add task: ${response.errorMessage!}',
      );
    }
  }

  @override
  void onClose() {
    titleTEController.dispose();
    descriptionTEController.dispose();
    super.onClose();
  }
}

class addTask extends StatelessWidget {
  const addTask({super.key});

  static const String name = '/add-new-task';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddTaskController());
    return Scaffold(
      appBar: appbar(),
      body: SingleChildScrollView(
        child: background(
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
                    'Add New Task',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.titleTEController,
                    textInputAction: TextInputAction.next,
                    validator: (String? value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Enter your title';
                      }
                      return null;
                    },
                    decoration: InputDecoration(hintText: 'Title'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.descriptionTEController,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                    },
                    maxLines: 5,
                    validator: (String? value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Enter your description';
                      }
                      return null;
                    },
                    decoration: InputDecoration(hintText: 'Description'),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => Visibility(
                    visible: !controller.addNewTaskInProgress.value,
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
}