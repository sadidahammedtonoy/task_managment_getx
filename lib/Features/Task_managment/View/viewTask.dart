import 'package:flutter/material.dart';
import 'package:task_manager/Features/Task_managment/Model/model.dart';
import 'package:task_manager/Features/Task_managment/Model/countModel.dart';
import 'package:task_manager/Network/network.dart';
import 'package:task_manager/Features/Global%20Widgets/progressIndicator.dart';
import '../../Global Widgets/date.dart';
import '../../../Const/urls.dart';
import '../../Global Widgets/snackbar.dart';
import '../../Global Widgets/card.dart';
import '../../Global Widgets/countCard.dart';
import 'taskDetails.dart';

class taskView extends StatefulWidget {
  const taskView({super.key});

  @override
  State<taskView> createState() => _taskViewState();
  static const String name = '/new-task-list';
}

class _taskViewState extends State<taskView> {
  List<TaskModel> _newTaskList = [];
  bool _isLoading = false;
  bool _taskCountSummaryLoading = false;
  List<TaskStatusCountModel> _taskCountSummaryList = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getNewTaskList();
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
              visible: _isLoading == false,
              replacement: CenteredCircularProgressIndicator(),
              child: Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 70),
                  itemCount: _newTaskList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => taskDetails(
                              title: _newTaskList[index].title!,
                              description: _newTaskList[index].description!,
                              createdDate: formatDate(
                                _newTaskList[index].createdDate!,
                              ),
                              status: _newTaskList[index].status!,
                            ),
                          ),
                        );
                      },
                      child: card(
                        taskType: TaskType.tNew,
                        taskModel: _newTaskList[index],
                        onTaskStatusUpdated: () {
                          _getTaskCountSummary();
                          _getNewTaskList();
                        },
                        onDeleteTask: () {
                          _getTaskCountSummary();
                          _getNewTaskList();
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

  Future<void> _getNewTaskList() async {
    _isLoading = true;
    if (mounted) {
      setState(() {});
    }

    NetworkResponse response = await networkCaller.getRequest(
      url: urls.GetNewTasksUrl,
    );
    if (response.isSuccess) {
      List<TaskModel> list = [];
      for (Map<String, dynamic> jsonData in response.body!['data']) {
        list.add(TaskModel.fromJson(jsonData));
      }
      _newTaskList = list;
    } else {
      if (mounted) {
        showSnackBarMessage(context, response.errorMessage!);
      }
    }

    _isLoading = false;
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
