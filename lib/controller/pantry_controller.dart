import 'package:get/get.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:kitsain_frontend_spring2023/LoginController.dart';
import 'package:kitsain_frontend_spring2023/controller/tasklist_controller.dart';
import 'package:kitsain_frontend_spring2023/controller/task_controller.dart';
import 'package:kitsain_frontend_spring2023/database/pantry_proxy.dart';

class PantryController {
  final _taskListController = Get.put(TaskListController());
  final _taskController = Get.put(TaskController());

  Future findPantryIndex() async {
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

  changeFormatOfExpiryDate(String expiryDate) {
    return expiryDate.replaceAll(' ', 'T');
  }

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

  Future<void> createPantryItemTask(Item pantryItem) async {
    final valuesString = createStringOfPantryItemValues(pantryItem);
    final taskListIndex = await checkIfPantryListExists();
    var expiryDateAsString = null;
    if (pantryItem.expiryDate != null) {
      expiryDateAsString =
          changeFormatOfExpiryDate(pantryItem.expiryDate.toString());
    }
    var googleTaskId = await _taskController.createTask(pantryItem.name,
        valuesString, taskListIndex.toString(), expiryDateAsString);
    pantryItem.googleTaskId = googleTaskId;
    PantryProxy().upsertItem(pantryItem);
  }

  createStringOfPantryItemValues(Item pantryItem) {
    var valuesString = "";
    valuesString += "location: ${pantryItem.location}\n";
    valuesString += "category: ${pantryItem.mainCat}\n";
    valuesString += "favorite: ${pantryItem.favorite}\n";
    valuesString += "opened date: ${pantryItem.openedDate}\n";
    valuesString += "added date: ${pantryItem.addedDate}\n";
    valuesString += "details: ${pantryItem.details}\n";
    return valuesString;
  }

  Future<void> editItemTasks(Item item) async {
    final taskListIndex = await findPantryIndex();
    var expiryDateAsString = null;
    if (item.expiryDate != null) {
      expiryDateAsString = changeFormatOfExpiryDate(item.expiryDate.toString());
    }
    print("pvm: ${item.addedDate}");
    final editedValuesString = createStringOfPantryItemValues(item);
    var googleTaskId = _taskController.editTask(item.name, editedValuesString,
        taskListIndex, item.googleTaskId as String, 0, expiryDateAsString);
  }
}
