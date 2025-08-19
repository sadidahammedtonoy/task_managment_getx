import 'package:get/get.dart';
import 'package:task_manager/Controller/cancelled_task_list_controller.dart';
import 'package:task_manager/Controller/task_card_controller.dart';
import '../Controller/add_new_task_controller.dart';
import '../Controller/completed_task_list_controller.dart';
import '../Controller/email_pin_varification_controller.dart';
import '../Controller/email_varification_controller.dart';
import '../Controller/new_task_list_controller.dart';
import '../Controller/progress_task_list_controller.dart';
import '../Controller/set_password_controller.dart';
import '../Controller/sign_in_controller.dart';
import '../Controller/sign_up_controller.dart';
import '../Controller/task_count_summary_controller.dart';
import '../Controller/update_profile_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.put(SignInController());
    Get.put(EmailVerificationController());
    Get.put(EmailPinVerificationController());
    Get.put(SetPasswordController());
    Get.put(SignUpController());
    Get.put(AddNewTaskController());
    Get.put(TaskCountSummaryController());
    Get.put(NewTaskListController());
    Get.put(ProgressTaskListController());
    Get.put(CancelledTaskListController());
    Get.put(CompletedTaskListController());
    Get.put(UpdateProfileController());
  }
}
