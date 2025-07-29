import 'package:flutter/material.dart';
import 'package:task_manager/Network/network.dart';
import 'package:task_manager/Features/Global%20Widgets/progressIndicator.dart';
import 'package:task_manager/Features/Global%20Widgets/snackbar.dart';
import '../../../Const/urls.dart';
import '../../Background/Background.dart';
import '../../appbar_navbar/appbar.dart';
import '../../appbar_navbar/navbar.dart';

class addTask extends StatefulWidget {
  const addTask({super.key});

  static const String name = '/add-new-task';

  @override
  State<addTask> createState() => _addTaskState();
}

class _addTaskState extends State<addTask> {
  final TextEditingController _titleTEController = TextEditingController();
  final TextEditingController _descriptionTEController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _addNewTaskInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: SingleChildScrollView(
        child: background(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
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
                    controller: _titleTEController,
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
                    controller: _descriptionTEController,
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
                  Visibility(
                    visible: _addNewTaskInProgress == false,
                    replacement: CenteredCircularProgressIndicator(),
                    child: ElevatedButton(
                      onPressed: _onTapSubmitButton,
                      child: Icon(Icons.arrow_circle_right_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _onTapSubmitButton() {
    if (_formKey.currentState!.validate()) {
      _addNewTask();
    }
  }

  Future<void> _addNewTask() async {
    _addNewTaskInProgress = true;
    setState(() {});

    Map<String, String> requestbody = {
      'title': _titleTEController.text.trim(),
      'description': _descriptionTEController.text.trim(),
      'status': 'New',
    };

    NetworkResponse response = await networkCaller.postRequest(
      url: urls.AddNewTaskUrl,
      body: requestbody,
    );

    _addNewTaskInProgress = false;
    if (mounted) {
      setState(() {});
    }

    if (response.isSuccess) {
      _titleTEController.clear();
      _descriptionTEController.clear();

      showSnackBarMessage(context, 'Task added successfully');
      Navigator.pushReplacementNamed(context, navbar.name);
    } else {
      showSnackBarMessage(
        context,
        'Failed to add task: ${response.errorMessage!}',
      );
    }
  }

  @override
  void dispose() {
    _titleTEController.dispose();
    _descriptionTEController.dispose();
    super.dispose();
  }
}
