import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';
import 'package:kitsain_frontend_spring2023/assets/top_bar.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:kitsain_frontend_spring2023/views/add_forms/create_recipe.dart';
import 'package:kitsain_frontend_spring2023/views/help_pages/pantry_help_page.dart';
import 'package:realm/realm.dart';
import 'package:get/get.dart';
import 'package:kitsain_frontend_spring2023/database/recipes_proxy.dart';
import 'package:kitsain_frontend_spring2023/assets/recipebuilder.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/controller/tasklist_controller.dart';
import 'package:kitsain_frontend_spring2023/controller/task_controller.dart';

class RecipeView extends StatefulWidget {
  const RecipeView({super.key});

  @override
  State<RecipeView> createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  @override
  void initState() {
    super.initState();
   // getRecipeTasks();
  }
  final _taskListController = Get.put(TaskListController());
  final _taskController = Get.put(TaskController());
  final _recipeProxy = RecipeProxy();
  String selectedView = "all";
  String selectedSort = "az";

  RealmResults<Recipe>? chosenStream(String selectedView) {
    if (selectedView == "all" || selectedView == "bycat") {
      return RecipeProxy().getRecipes(selectedSort);
    } else if (selectedView == "favorites") {
      return RecipeProxy().getRecipes(selectedSort);
    }
    return null;
  }

  void _createNewRecipe() {
    _showModalBottomSheet(const CreateNewRecipeForm());
  }

  void _showHelp() {
    _showModalBottomSheet(const PantryHelp());
  }

  void _showModalBottomSheet(Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          child: content,
        );
      },
    );
  }

  /*
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
  
  saveRecipeTasksToRealm(index) async {
    // _pantryProxy.deleteAll();
    var realmItems = await RecipeProxy().getItems();
    var tasks = await _taskController.getTasksList(index);
    for (var i = 0; i < tasks.items.length; i++) {
      print(tasks.items[i].title);
      // Implement if googleTaskId not same as in realm insert item
      _recipeProxy.upsertRecipe(Recipe(
        ObjectId().toString(),
        tasks.items[i].title,
        selectedItems: tasks.items[i].selectedItems, 
        recipeType: tasks.items[i].recipeType,
        supplies: tasks.items[i].supplies,
        expSoon: tasks.items[i].expSoon,
        pantryonly: tasks.items[i].pantryonly,
        ));
    }
  }

  getRecipeTasks() async {
    
    await _taskListController.getTaskLists();
    var index = await checkIfRecipeListExists();
    
    if (index == "not") {
      await createRecipeTaskList();
    }
    await saveRecipeTasksToRealm(index);
    var realmItems = await RecipeProxy().getItems();
    print(realmItems);
    setState(() {});
  }
    */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main2,
      appBar: TopBar(
        title: AppLocalizations.of(context)!.recipeScreen,
        addFunction: _createNewRecipe,
        helpFunction: _showHelp,
        backgroundImageName: 'assets/images/pantry_banner_B1.jpg',
        titleBackgroundColor: AppColors.titleBackgroundBrown,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return DragTarget<Item>(
      builder: (context, candidateData, rejectedData) {
        return ListView(
          children: [
            _buildFilterSortRow(),
            _buildRecipesStream(),
          ],
        );
      },
    );
  }

  Widget _buildFilterSortRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildPopupMenuButton("all", Icons.tune, "ALL"),
        const SizedBox(width: 5),
        _buildPopupMenuButton("favorites", Icons.filter_list, "A - Z"),
        const SizedBox(width: 10),
      ],
    );
  }

  PopupMenuButton<String> _buildPopupMenuButton(String value, IconData icon, String buttonText) {
    return PopupMenuButton(
      initialValue: value,
      onSelected: (value) {
        setState(() {
          selectedView = value.toString();
        });
      },
      child: Icon(
        icon,
        size: 30,
      ),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: value,
            child: Text(
              buttonText,
              style: AppTypography.smallTitle,
            ),
          ),
        ];
      },
    );
  }

  Widget _buildRecipesStream() {
    return StreamBuilder<RealmResultsChanges<Recipe>>(
      stream: chosenStream(selectedView)?.changes,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return const CircularProgressIndicator(); // while loading data
        }
        final results = data.results;

        if (results.isEmpty) {
          return Center(
            child: Text(
              "No recipes found",
              style: AppTypography.smallTitle,
            ),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                child: Text(
                  "ALL ITEMS",
                  style: AppTypography.heading3,
                ),
              ),
              RecipeBuilder(
                recipes: results,
                sortMethod: selectedSort,
              ),
            ],
          );
        }
      },
    );
  }
}
