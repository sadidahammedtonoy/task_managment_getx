import 'package:flutter/material.dart';
import 'package:task_manager/Features/Task_managment/View/viewTask.dart';
import 'appbar.dart';
import '../Task_managment/View/addTask.dart';
import '../Task_managment/View/canceledTask.dart';
import '../Task_managment/View/completeTask.dart';
import '../Task_managment/View/progressTask.dart';

class navbar extends StatefulWidget {
  const navbar({super.key});

  static const String name = '/main-nav-bar-holder';

  @override
  State<navbar> createState() => _navbarState();
}

class _navbarState extends State<navbar> {
  final List<Widget> _screens = [
    taskView(),
    ProgressTaskList(),
    CompletedTaskList(),
    CanceledTaskList(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
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
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _onTapAddNewTaskButton,
        child: Icon(Icons.add),
      ),
    );
  }

  void _onTapAddNewTaskButton() {
    Navigator.pushNamed(context, addTask.name).then((value) {
      if (value == true) {
        setState(() {});
      }
    });
  }
}
