import 'package:get/get.dart';
import 'package:googleapis/tasks/v1.dart';
import 'package:kitsain_frontend_spring2023/LoginController.dart';
import 'package:kitsain_frontend_spring2023/models/ShoppingListItemModel.dart';

class TaskController extends GetxController {
  var tasksListRemove = Rx<List<int>?>([]);
  var shoppingListItem = Rx<List<ShoppingListItemModel>?>([]);

  final loginController = Get.put(LoginController());

  getTasksList(String taskListId) async {
    var tskList = await loginController.taskApiAuthenticated.value?.tasks
        .list(taskListId);
    shoppingListItem.value?.clear();
    tskList?.items?.forEach((element) {
      var newItem = ShoppingListItemModel(
          '${element.title}',
          element.notes == null ? '' : '${element.notes}',
          false,
          '${element.id}');
      shoppingListItem.value?.add(newItem);
    });

    shoppingListItem.refresh();

    return tskList;
  }

  createTask(String title, String description, String taskListId,
      [String? due]) async {
    var newTask = Task(title: title, notes: description, status: "needsAction");

    if (due != null) {
      DateTime dueDateTime = DateTime.parse(due);
      String formattedDueDate = dueDateTime.toIso8601String();
      newTask.due = formattedDueDate;
    }

    var googleTaskId;
    await loginController.taskApiAuthenticated.value!.tasks
        .insert(newTask, taskListId)
        .then((value) async {
      // print('ok ${value.id}');
      googleTaskId = value.id;
      var newItem =
          ShoppingListItemModel(title, description, false, '${value.id}');
      shoppingListItem.value?.add(newItem);
      await getTasksList(taskListId);
      // tasksList.value?.items?.add(value);
      shoppingListItem.refresh();
    });
    return googleTaskId;
  }

  editTask(String title, String description, String taskListId, String taskId,
      int index,
      [String? due]) async {
    var newItem = ShoppingListItemModel(title, description, false, taskId);
    shoppingListItem.value?.insert(index, newItem);

    var newTask = Task(
        title: title, notes: description, status: "needsAction", id: taskId);
    if (due != null) {
      DateTime dueDateTime = DateTime.parse(due);
      String formattedDueDate = dueDateTime.toUtc().toIso8601String();
      newTask.due = formattedDueDate;
    }
    // print('tlid ' + taskListId + ' tid ' + taskId);
    var googleTaskId;
    await loginController.taskApiAuthenticated.value!.tasks
        .update(
      newTask,
      taskListId,
      taskId,
    )
        .then((value) async {
      googleTaskId = value.id;
      await getTasksList(taskListId);
      // tasksList.value?.items?[index] = newTask;
      shoppingListItem.refresh();
    });
  }

  deleteTask(String taskListId, String taskId, int index) async {
    // print(' $taskListId    $taskId     $index     ');

    await loginController.taskApiAuthenticated.value!.tasks
        .delete(
      taskListId,
      taskId,
    )
        .then((value) async {
      await getTasksList(taskListId);
      shoppingListItem.refresh();

      // tasksList.value?.items?.removeAt(index);
    });
  }
}
