import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/Features/Task_managment/View/viewTask.dart';
import 'appbar.dart';
import '../Task_managment/View/addTask.dart';
import '../Task_managment/View/canceledTask.dart';
import '../Task_managment/View/completeTask.dart';
import '../Task_managment/View/progressTask.dart';

class NavbarController extends GetxController {
  var selectedIndex = 0.obs;

  final List<Widget> screens = [
    taskView(),
    ProgressTaskList(),
    CompletedTaskList(),
    CanceledTaskList(),
  ];

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  void onTapAddNewTaskButton() {
    Get.toNamed(addTask.name)?.then((value) {
      if (value == true) {
        Get.find<NavbarController>().refresh();
      }
    });
  }
}

class navbar extends StatelessWidget {
  const navbar({super.key});

  static const String name = '/main-nav-bar-holder';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavbarController());
    return Scaffold(
      appBar: appbar(),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(() => NavigationBar(
        selectedIndex: controller.selectedIndex.value,
        onDestinationSelected: (int index) {
          controller.changeIndex(index);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.new_label_outlined),
            label: 'New',
          ),
          NavigationDestination(
            icon: Icon(Icons.arrow_circle_right_outlined),
            label: 'Progress',
          ),
          NavigationDestination(icon: Icon(Icons.done), label: 'Completed'),
          NavigationDestination(icon: Icon(Icons.close), label: 'Cancelled'),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.onTapAddNewTaskButton,
        child: Icon(Icons.add),
      ),
    );
  }
}