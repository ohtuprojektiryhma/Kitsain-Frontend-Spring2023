import 'package:get/get.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:kitsain_frontend_spring2023/controller/tasklist_controller.dart';
import 'package:kitsain_frontend_spring2023/controller/task_controller.dart';
import 'package:kitsain_frontend_spring2023/database/recipes_proxy.dart';
import 'package:realm/realm.dart';


class RecipeController {
  final _taskListController = Get.put(TaskListController());
  final _taskController = Get.put(TaskController());
  final _recipeProxy = RecipeProxy();

  createRecipeTaskList() async {
    var recipesFound = await checkIfRecipeListExists();
    print("recipesfound: ${recipesFound}");
    if (recipesFound == "not") {
      _taskListController.createTaskLists("My Recipes");
    }
    await getRecipeTasks();
    }

  Future checkIfRecipeListExists() async {
    await _taskListController.getTaskLists();
    var recipeIndex = "not";
    if (_taskListController.taskLists.value?.items != null) {
      int length = _taskListController.taskLists.value?.items!.length as int;
      for (var i = 0; i < length; i++) {
        if (_taskListController.taskLists.value?.items?[i].title ==
            "My Recipes") {
          recipeIndex =
              _taskListController.taskLists.value?.items?[i].id as String;
          break;
        }
      }
    }
    return recipeIndex;
  }

  bool checkIfRecipeInrealm(String googleTaskId, RealmResults<Recipe> realmItems) {
    var googleTaskIdList = realmItems.map((e) => e.googleTaskId);
    if (googleTaskIdList.contains(googleTaskId)) {
      return true;
    }
    else {
      return false;
    }
  }

  bool checkIfItemInGoogleTasks(String? googleTaskId, tasks) {
    var googleTaskIdList = tasks.items.map((e) => e.id);
    if (googleTaskIdList.contains(googleTaskId)) {
      return true;
    }
    else {
      return false;
    }
  }
  
  saveRecipeTasksToRealm(realmItems, tasks,) async {
    for (var i = 0; i < tasks.items.length; i++) {
      if (!checkIfRecipeInrealm(tasks.items[i].id, realmItems)) {
        var item = Recipe(
          ObjectId().toString(),
          tasks.items[i].title,
          instructions: getInstructions(tasks.items[i].notes),
          ingredients: getIngredients(tasks.items[i].notes),
          googleTaskId: tasks.items[i].id,
        );
        _recipeProxy.upsertRecipe(item);
      }
    }
  }
  List<String> getInstructions(String notes) {
    RegExp exp = RegExp(r'Instructions: \[(.*?)\]');
    Iterable<RegExpMatch> matches = exp.allMatches(notes);
    if (matches.isNotEmpty) {
      String instructionsString = matches.first.group(1) ?? "";
      return instructionsString.split(',').map((instruction) => instruction.trim()).toList();
    }
    return [];
  }

  Map<String, String> getIngredients(String notes) {
    RegExp exp = RegExp(r'Ingredients: {(.*?)}');
    Iterable<RegExpMatch> matches = exp.allMatches(notes);
    if (matches.isNotEmpty) {
      String ingredientsString = matches.first.group(1) ?? "";
      List<String> ingredientsList = ingredientsString.split(',').map((ingredient) => ingredient.trim()).toList();
      Map<String, String> ingredientsMap = {};
      ingredientsList.forEach((ingredient) {
        List<String> parts = ingredient.split(':');
        if (parts.length == 2) {
          ingredientsMap[parts[0].trim()] = parts[1].trim();
        }
      });
      return ingredientsMap;
    }
    return {};
  }

  deleteMissingGoogleTasksFromRealm(RealmResults<Recipe> realmItems, tasks) async {
    for (var i = 0; i < realmItems.length; i++) {
      if (!checkIfItemInGoogleTasks(realmItems[i].googleTaskId, tasks)) {
        _recipeProxy.deleteRecipe(realmItems[i]);
      }
    }
  }
  
  syncPantryTasksWithRealm(index) async {
    var realmItems = await RecipeProxy().getRecipes();
    var tasks = await _taskController.getTasksList(index);
    print("testing");
    saveRecipeTasksToRealm(realmItems, tasks);
    deleteMissingGoogleTasksFromRealm(realmItems, tasks);
  } 

  getRecipeTasks() async {
    await _taskListController.getTaskLists();
    var index = await checkIfRecipeListExists();
    if (index == "not") {
      await _taskListController.createTaskLists("My Recipes");
      index = await checkIfRecipeListExists();
    }
    await syncPantryTasksWithRealm(index);
    var realmItems = await RecipeProxy().getItems();
    print(realmItems);
  }

}