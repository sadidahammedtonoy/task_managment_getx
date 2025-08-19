import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/task_card_controller.dart';
import '../Model/Task_Model.dart';
import '../ui/utils/DateFormat.dart';
import 'Center_circular_progress_bar.dart';

enum TaskType { tNew, progress, completed, cancelled }

class TaskCard extends StatelessWidget {
  final TaskType taskType;
  final TaskModel taskModel;
  final VoidCallback onTaskStatusUpdated;
  final VoidCallback onDeleteTask;

  const TaskCard({
    super.key,
    required this.taskType,
    required this.taskModel,
    required this.onTaskStatusUpdated,
    required this.onDeleteTask,
  });

  String _getTaskTypeName(TaskType type) {
    switch (type) {
      case TaskType.tNew:
        return 'New';
      case TaskType.progress:
        return 'Progress';
      case TaskType.completed:
        return 'Completed';
      case TaskType.cancelled:
        return 'Cancelled';
    }
  }

  Color _getTaskChipColor(TaskType type) {
    switch (type) {
      case TaskType.tNew:
        return Colors.blue;
      case TaskType.progress:
        return Colors.purple;
      case TaskType.completed:
        return Colors.green;
      case TaskType.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskCardController>(
      init: TaskCardController(taskModel: taskModel),
      global: false, // ensures controller is not reused globally
      builder: (controller) {
        return Card(
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  taskModel.title ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  taskModel.description ?? '',
                  style: TextStyle(color: Colors.black54),
                ),
                Text(formatDate(taskModel.createdDate!)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        _getTaskTypeName(taskType),
                        style: const TextStyle(color: Colors.white),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      backgroundColor: _getTaskChipColor(taskType),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Spacer(),
                    Visibility(
                      visible: controller.updateTaskStatusInProgress == false,
                      replacement: CenteredCircularProgressIndicator(),
                      child: IconButton(
                        onPressed: () =>
                            _showEditTaskStatusDialog(context, controller),
                        icon: Icon(Icons.edit, color: Colors.green),
                      ),
                    ),
                    Visibility(
                      visible: controller.deleteTaskInProgress == false,
                      replacement: CenteredCircularProgressIndicator(),
                      child: IconButton(
                        onPressed: () =>
                            controller.deleteTask(onDeleteTask, context),
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditTaskStatusDialog(
    BuildContext context,
    TaskCardController controller,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Update Task Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: TaskType.values.map((type) {
              return ListTile(
                title: Text(_getTaskTypeName(type)),
                trailing: taskType == type ? Icon(Icons.check) : null,
                onTap: () {
                  if (taskType != type) {
                    controller.updateTaskStatus(
                      _getTaskTypeName(type),
                      context,
                      onTaskStatusUpdated,
                    );
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
