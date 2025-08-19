import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:task_manager/Network/network_caller.dart';
import 'package:task_manager/widget/Center_circular_progress_bar.dart';
import '../../Controller/progress_task_list_controller.dart';
import '../../Controller/task_count_summary_controller.dart';
import '../../Model/Task_Model.dart';
import '../../widget/Snackbar_Messages.dart';
import '../../widget/Task_card.dart';
import '../../widget/Task_count_summary_card.dart';
import '../utils/DateFormat.dart';
import '../utils/urls.dart';
import 'Show_Task_Details.dart';

class ProgressTaskList extends StatefulWidget {
  const ProgressTaskList({super.key});

  @override
  State<ProgressTaskList> createState() => _ProgressTaskListState();
}

class _ProgressTaskListState extends State<ProgressTaskList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ProgressTaskListController>().getProgressTaskList();
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
              },
            ),
            GetBuilder<ProgressTaskListController>(
              builder: (controller) {
                return Visibility(
                  visible: controller.isLoading == false,
                  replacement: CenteredCircularProgressIndicator(),
                  child: Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 70),
                      itemCount: controller.progressTaskList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ShowTaskDetails(
                                  title:
                                      controller.progressTaskList[index].title!,
                                  description: controller
                                      .progressTaskList[index]
                                      .description!,
                                  createdDate: formatDate(
                                    controller
                                        .progressTaskList[index]
                                        .createdDate!,
                                  ),
                                  status: controller
                                      .progressTaskList[index]
                                      .status!,
                                ),
                              ),
                            );
                          },
                          child: TaskCard(
                            taskType: TaskType.progress,
                            taskModel: controller.progressTaskList[index],
                            onTaskStatusUpdated: () {
                              Get.find<TaskCountSummaryController>()
                                  .getTaskCountSummary();
                              Get.find<ProgressTaskListController>()
                                  .getProgressTaskList();
                            },
                            onDeleteTask: () {
                              Get.find<TaskCountSummaryController>()
                                  .getTaskCountSummary();
                              Get.find<ProgressTaskListController>()
                                  .getProgressTaskList();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
