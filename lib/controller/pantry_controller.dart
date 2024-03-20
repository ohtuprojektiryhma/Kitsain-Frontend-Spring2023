import 'package:get/get.dart';
import 'package:googleapis/tasks/v1.dart';
import 'package:kitsain_frontend_spring2023/LoginController.dart';
import 'package:kitsain_frontend_spring2023/controller/tasklist_controller.dart';

class PantryController {
  final _taskListController = Get.put(TaskListController());

  Future checkIfPantryListExists() async {
    await _taskListController.getTaskLists();
    var pantryIndex = "not";
    if (_taskListController.taskLists.value?.items != null) {
      int length = _taskListController.taskLists.value?.items!.length as int;
      for (var i = 0; i < length; i++) {
        print("${i}: ${_taskListController.taskLists.value?.items?[i].title}");
        if (_taskListController.taskLists.value?.items?[i].title ==
            "My Pantry") {
          pantryIndex =
              _taskListController.taskLists.value?.items?[i].id as String;
          break;
        }
      }
    }
    return pantryIndex;
  }

  Future checkIfPantryItemExists(
      String pantryItemGoogleTaskIndex, String taskListIndex) async {
    await _taskListController.getTaskLists();
    if (_taskListController.taskLists.value?.items != null) {
      int length = _taskListController.taskLists.value?.items!.length as int;
      for (var i = 0; i < length; i++) {
        if (_taskListController.taskLists.value?.items?[i].id as String ==
            taskListIndex) {
          break;
        }
      }
    }
  }
}
