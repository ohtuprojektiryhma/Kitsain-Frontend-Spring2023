import 'package:get/get.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:kitsain_frontend_spring2023/LoginController.dart';
import 'package:kitsain_frontend_spring2023/controller/tasklist_controller.dart';
import 'package:kitsain_frontend_spring2023/controller/task_controller.dart';
import 'package:kitsain_frontend_spring2023/database/pantry_proxy.dart';
import 'package:realm/realm.dart';

class PantryController {
  final _taskListController = Get.put(TaskListController());
  final _taskController = Get.put(TaskController());
  final _pantryProxy = PantryProxy();

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

  addADayToOpenedDate(Item item) {
    print(DateTime(item.openedDate!.year, item.openedDate!.month,
        item.openedDate!.day + 1));
    return DateTime(item.openedDate!.year, item.openedDate!.month,
        item.openedDate!.day + 1);
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
    print("opening date 3: ${item.openedDate}");
    final taskListIndex = await findPantryIndex();
    var expiryDateAsString = null;
    if (item.expiryDate != null) {
      expiryDateAsString = changeFormatOfExpiryDate(item.expiryDate.toString());
    }
    final editedValuesString = createStringOfPantryItemValues(item);
    var googleTaskId = _taskController.editTask(item.name, editedValuesString,
        taskListIndex, item.googleTaskId as String, 0, expiryDateAsString);
  }

  String _ignoreSubMicro(String s) {
    // Makes the rfc timestamp able to be parsed through DateTime parser
    if (s.length > 27) return s.substring(0, 26) + s[s.length - 1];
    return s;
  }

  DateTime convertToRealmDateTime(String dateString) {
    // Parse the date string into a DateTime object
    DateTime dateTime = DateTime.parse(_ignoreSubMicro(dateString));
    return dateTime;
  }

  Item parseDescriptionStringFromGoogleTask(String description, Item item) {
    // Split the valuesString by newline characters
    List<String> lines = description.split('\n');

    // Loop through each line
    lines.forEach((line) {
      // Split each line by colon (:) to separate property name and value
      List<String> parts = line.split(':');

      // Trim any leading or trailing whitespaces from property name and value
      String propertyName = parts[0].trim();
      String propertyValue = parts.length > 1 ? parts[1].trim() : '';

      // Assign values to item properties based on property name
      switch (propertyName) {
        case 'location':
          if (propertyValue != "null") {
            item.location = propertyValue;
          }
          break;
        case 'category':
          if (propertyValue != "null") {
            item.mainCat = int.parse(propertyValue);
          }
          break;
        case 'favorite':
          if (propertyValue != "null") {
            bool favorite = propertyValue == 'true';
            item.favorite = favorite;
          }
          break;
        case 'opened date':
          if (propertyValue != "null") {
            item.openedDate = DateTime.parse(propertyValue);
          }
          break;
        case 'added date':
          if (propertyValue != "null") {
            item.addedDate = DateTime.parse(propertyValue);
          }
          break;
        case 'details':
          if (propertyValue != "null") {
            item.details = propertyValue;
          }
          break;
      }
    });
    return item;
  }

  bool checkIfItemInrealm(String googleTaskId, RealmResults<Item> realmItems) {
    var googleTaskIdList = realmItems.map((e) => e.googleTaskId);
    if (googleTaskIdList.contains(googleTaskId)) {
      return true;
    } else {
      return false;
    }
  }

  bool checkIfItemInGoogleTasks(String? googleTaskId, tasks) {
    var googleTaskIdList = tasks.items.map((e) => e.id);
    if (googleTaskIdList.contains(googleTaskId)) {
      return true;
    } else {
      return false;
    }
  }

  saveGoogleTasksToRealm(realmItems, tasks) {
    var notes = "";
    for (var i = 0; i < tasks.items.length; i++) {
      if (!checkIfItemInrealm(tasks.items[i].id, realmItems)) {
        var item = Item(
            ObjectId().toString(), tasks.items[i].title, "Pantry", 1,
            googleTaskId: tasks.items[i].id);
        if (tasks.items[i].due != null) {
          item.expiryDate = convertToRealmDateTime(tasks.items[i].due);
        }
        if (tasks.items[i].notes != null) {
          notes = tasks.items[i].notes;
        }
        item = parseDescriptionStringFromGoogleTask(notes, item);
        _pantryProxy.upsertItem(item);
      }
    }
  }

  deleteMissingGoogleTasksFromRealm(
      RealmResults<Item> realmItems, tasks) async {
    for (var i = 0; i < realmItems.length; i++) {
      if (!checkIfItemInGoogleTasks(realmItems[i].googleTaskId, tasks)) {
        _pantryProxy.deleteItem(realmItems[i]);
      }
    }
  }

  syncPantryTasksWithRealm(index) async {
    var realmItems = await PantryProxy().getPantryItems();
    var tasks = await _taskController.getTasksList(index);
    saveGoogleTasksToRealm(realmItems, tasks);
    deleteMissingGoogleTasksFromRealm(realmItems, tasks);
  }

  getPantryTasks() async {
    await _taskListController.getTaskLists();
    var index = await checkIfPantryListExists();
    if (index == "not") {
      await _taskListController.createTaskLists("My Pantry");
      index = await checkIfPantryListExists();
    }
    await syncPantryTasksWithRealm(index);
    var realmItems = await PantryProxy().getItems();
    print("REALM ITEMS: ");
    for (var i = 0; i < realmItems.length; i++) {
      print(realmItems[i].name);
      print(realmItems[i].expiryDate);
      print("");
    }
  }
}
