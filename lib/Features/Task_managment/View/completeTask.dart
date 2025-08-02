import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/Features/Global%20Widgets/progressIndicator.dart';
import '../../Global Widgets/date.dart';
import '../../../Const/urls.dart';
import '../Model/model.dart';
import '../Model/countModel.dart';
import '../../../Network/network.dart';
import '../../Global Widgets/snackbar.dart';
import '../../Global Widgets/card.dart';
import '../../Global Widgets/countCard.dart';
import 'taskDetails.dart';
final NetworkCaller controller = Get.put(NetworkCaller());
class CompletedTaskListController extends GetxController {
  var completedTaskList = <TaskModel>[].obs;
  var isLoading = false.obs;
  var taskCountSummaryLoading = false.obs;
  var taskCountSummaryList = <TaskStatusCountModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getCompletedTaskList();
    getTaskCountSummary();
  }

  Future<void> getCompletedTaskList() async {
    isLoading.value = true;

    NetworkResponse response = await controller.getRequest(
      url: urls.CompletedTasksUrl,
    );

    if (response.isSuccess) {
      List<TaskModel> list = [];
      for (Map<String, dynamic> jsonData in response.body!['data']) {
        list.add(TaskModel.fromJson(jsonData));
      }
      completedTaskList.assignAll(list);
    } else {
      showSnackBarMessage(
        Get.context!,
        'Failed to load completed tasks: ${response.errorMessage!}',
      );
    }

    isLoading.value = false;
  }

  Future<void> getTaskCountSummary() async {
    taskCountSummaryLoading.value = true;

    NetworkResponse response = await controller.getRequest(
      url: urls.GetAllTasksUrl,
    );

    if (response.isSuccess) {
      List<TaskStatusCountModel> list = [];
      for (Map<String, dynamic> jsonData in response.body!['data']) {
        list.add(TaskStatusCountModel.fromJson(jsonData));
      }
      list.sort((a, b) => b.sum!.compareTo(a.sum!));
      taskCountSummaryList.assignAll(list);
    } else {
      showSnackBarMessage(Get.context!, response.errorMessage!);
    }

    taskCountSummaryLoading.value = false;
  }
}

class CompletedTaskList extends StatelessWidget {
  const CompletedTaskList({super.key});

  static const String name = '/completed-task-list';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompletedTaskListController());
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Obx(() => Visibility(
              visible: !controller.taskCountSummaryLoading.value,
              replacement: CenteredCircularProgressIndicator(),
              child: SizedBox(
                height: 100,
                child: Obx(() => ListView.separated(
                  itemCount: controller.taskCountSummaryList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return countcard(
                      title: controller.taskCountSummaryList[index].sId!,
                      count: controller.taskCountSummaryList[index].sum!,
                    );
                  },
                  separatorBuilder: (context, index) =>
                  const SizedBox(width: 4),
                )),
              ),
            )),
            Obx(() => Visibility(
              visible: !controller.isLoading.value,
              replacement: CenteredCircularProgressIndicator(),
              child: Expanded(
                child: Obx(() => ListView.builder(
                  itemCount: controller.completedTaskList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => taskDetails(
                          title: controller
                              .completedTaskList[index].title!,
                          description: controller
                              .completedTaskList[index].description!,
                          createdDate: formatDate(controller
                              .completedTaskList[index].createdDate!),
                          status: controller
                              .completedTaskList[index].status!,
                        ));
                      },
                      child: card(
                        taskType: TaskType.completed,
                        taskModel: controller.completedTaskList[index],
                        onTaskStatusUpdated: () {
                          controller.getTaskCountSummary();
                          controller.getCompletedTaskList();
                        },
                        onDeleteTask: () {
                          controller.getTaskCountSummary();
                          controller.getCompletedTaskList();
                        },
                      ),
                    );
                  },
                )),
              ),
            )),
          ],
        ),
      ),
    );
  }
}