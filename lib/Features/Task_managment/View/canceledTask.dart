import 'package:flutter/material.dart';
import 'package:task_manager/Features/Task_managment/Model/model.dart';
import 'package:task_manager/Network/network.dart';
import 'package:task_manager/Features/Global%20Widgets/progressIndicator.dart';
import '../../Global Widgets/date.dart';
import '../../../Const/urls.dart';
import '../Model/countModel.dart';
import '../../Global Widgets/snackbar.dart';
import '../../Global Widgets/card.dart';
import '../../Global Widgets/countCard.dart';
import 'taskDetails.dart';

class CanceledTaskList extends StatefulWidget {
  const CanceledTaskList({super.key});

  @override
  State<CanceledTaskList> createState() => _CanceledTaskListState();
}

class _CanceledTaskListState extends State<CanceledTaskList> {
  List<TaskModel> _canceledTaskList = [];
  bool _CancelledTaskisLoading = false;
  bool _taskCountSummaryLoading = false;
  List<TaskStatusCountModel> _taskCountSummaryList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCancelledTaskList();
      _getTaskCountSummary();
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
            Visibility(
              visible: _taskCountSummaryLoading == false,
              replacement: CenteredCircularProgressIndicator(),
              child: SizedBox(
                height: 100,
                child: ListView.separated(
                  itemCount: _taskCountSummaryList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return countcard(
                      title: _taskCountSummaryList[index].sId!,
                      count: _taskCountSummaryList[index].sum!,
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 4),
                ),
              ),
            ),
            Visibility(
              visible: _CancelledTaskisLoading == false,
              replacement: CenteredCircularProgressIndicator(),
              child: Expanded(
                child: ListView.builder(
                  itemCount: _canceledTaskList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => taskDetails(
                              title: _canceledTaskList[index].title!,
                              description:
                                  _canceledTaskList[index].description!,
                              createdDate: formatDate(
                                _canceledTaskList[index].createdDate!,
                              ),
                              status: _canceledTaskList[index].status!,
                            ),
                          ),
                        );
                      },
                      child: card(
                        taskType: TaskType.cancelled,
                        taskModel: _canceledTaskList[index],
                        onTaskStatusUpdated: () {
                          _getTaskCountSummary();
                          _getCancelledTaskList();
                        },
                        onDeleteTask: () {
                          _getTaskCountSummary();
                          _getCancelledTaskList();
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCancelledTaskList() async {
    _CancelledTaskisLoading = true;
    if (mounted) {
      setState(() {});
    }

    NetworkResponse response = await networkCaller.getRequest(
      url: urls.CancelledTasksUrl,
    );

    if (response.isSuccess) {
      _CancelledTaskisLoading = true;
      final List<TaskModel> list = [];

      for (Map<String, dynamic> jsonData in response.body!['data']) {
        list.add(TaskModel.fromJson(jsonData));
      }
      _canceledTaskList = list;
    } else {
      if (mounted) {
        showSnackBarMessage(
          context,
          'Failed to load cancelled tasks: ${response.errorMessage!}',
        );
      }
    }

    _CancelledTaskisLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _getTaskCountSummary() async {
    _taskCountSummaryLoading = true;

    if (mounted) {
      setState(() {});
    }

    NetworkResponse response = await networkCaller.getRequest(
      url: urls.GetAllTasksUrl,
    );

    if (response.isSuccess) {
      List<TaskStatusCountModel> list = [];
      for (Map<String, dynamic> jsonData in response.body!['data']) {
        list.add(TaskStatusCountModel.fromJson(jsonData));
      }
      list.sort((a, b) => b.sum!.compareTo(a.sum!));
      _taskCountSummaryList = list;
    } else {
      if (mounted) {
        showSnackBarMessage(context, response.errorMessage!);
      }
    }

    _taskCountSummaryLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
