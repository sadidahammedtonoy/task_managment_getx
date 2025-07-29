import 'package:flutter/material.dart';
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

class CompletedTaskList extends StatefulWidget {
  const CompletedTaskList({super.key});

  @override
  State<CompletedTaskList> createState() => _CompletedTaskListState();
}

class _CompletedTaskListState extends State<CompletedTaskList> {
  List<TaskModel> _completedTaskList = [];
  bool _CompletedTaskisLoading = false;
  bool _taskCountSummaryLoading = false;
  List<TaskStatusCountModel> _taskCountSummaryList = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getTaskCountSummary();
      _CompletedTaskList();
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
              visible: _CompletedTaskisLoading == false,
              replacement: CenteredCircularProgressIndicator(),
              child: Expanded(
                child: ListView.builder(
                  itemCount: _completedTaskList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => taskDetails(
                              title: _completedTaskList[index].title!,
                              description:
                                  _completedTaskList[index].description!,
                              createdDate: formatDate(
                                _completedTaskList[index].createdDate!,
                              ),
                              status: _completedTaskList[index].status!,
                            ),
                          ),
                        );
                      },
                      child: card(
                        taskType: TaskType.completed,
                        taskModel: _completedTaskList[index],
                        onTaskStatusUpdated: () {
                          _getTaskCountSummary();
                          _CompletedTaskList();
                        },
                        onDeleteTask: () {
                          _getTaskCountSummary();
                          _CompletedTaskList();
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

  Future<void> _CompletedTaskList() async {
    _CompletedTaskisLoading = true;
    setState(() {});

    NetworkResponse response = await networkCaller.getRequest(
      url: urls.CompletedTasksUrl,
    );

    if (response.isSuccess) {
      List<TaskModel> list = [];
      for (Map<String, dynamic> jsonData in response.body!['data']) {
        list.add(TaskModel.fromJson(jsonData));
      }
      _completedTaskList = list;
    } else {
      showSnackBarMessage(
        context,
        'Failed to load completed tasks: ${response.errorMessage!}',
      );
    }

    _CompletedTaskisLoading = false;
    setState(() {});
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
