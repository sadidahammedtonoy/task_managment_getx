import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/Controller/new_task_list_controller.dart';
import 'package:task_manager/Model/Task_Model.dart';
import 'package:task_manager/Model/Task_Status_Count_Model.dart';
import 'package:task_manager/Network/network_caller.dart';
import 'package:task_manager/ui/screens/Add_new_task_screen.dart';
import 'package:task_manager/widget/Center_circular_progress_bar.dart';
import '../../Controller/task_count_summary_controller.dart';
import '../../widget/Snackbar_Messages.dart';
import '../../widget/Task_card.dart';
import '../../widget/Task_count_summary_card.dart';
import '../utils/DateFormat.dart';
import '../utils/urls.dart';
import 'Show_Task_Details.dart';

class NewTaskList extends StatefulWidget {
  const NewTaskList({super.key});

  @override
  State<NewTaskList> createState() => _NewTaskListState();
  static const String name = '/new-task-list';
}

class _NewTaskListState extends State<NewTaskList> {


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
     Get.find<NewTaskListController>().getNewTaskList();
     Get.find<TaskCountSummaryController>().getTaskCountSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            const SizedBox(height: 16),
            GetBuilder<TaskCountSummaryController>(
              builder: (controller) {
                return Visibility(
                  visible: controller.isLoading == false,
                  replacement: CenteredCircularProgressIndicator(),
                  child: SizedBox(
                    height: 100,
                    child: ListView.separated(
                      itemCount: controller.taskCountSummaryList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return TaskCountSummaryCard(
                          title: controller.taskCountSummaryList[index].sId!,
                          count: controller.taskCountSummaryList[index].sum!,
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 4),
                    ),
                  ),
                );
              }
            ),

              GetBuilder<NewTaskListController>(
                builder: (controller) {
                  return Visibility(
                    visible: controller.isLoading == false,
                    replacement: CenteredCircularProgressIndicator(),
                    child: Expanded(

                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 70),
                        itemCount: controller.newTaskList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ShowTaskDetails(
                                    title: controller.newTaskList[index].title!,
                                    description: controller.newTaskList[index].description!,
                                    createdDate: formatDate(controller.newTaskList[index].createdDate!),
                                    status:controller.newTaskList[index].status!,
                                  ),
                                ),
                              );
                            },
                            child: TaskCard(
                              taskType: TaskType.tNew,
                              taskModel: controller.newTaskList[index],
                              onTaskStatusUpdated: () {
                                Get.find<TaskCountSummaryController>().getTaskCountSummary();
                                Get.find<NewTaskListController>().getNewTaskList();
                              },
                              onDeleteTask: () {
                                Get.find<TaskCountSummaryController>().getTaskCountSummary();
                                Get.find<NewTaskListController>().getNewTaskList();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              ),
          ],
        ),

      ),

    );
  }
}
