import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';
import 'package:kitsain_frontend_spring2023/assets/top_bar.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:kitsain_frontend_spring2023/views/add_forms/add_new_item_form.dart';
import 'package:kitsain_frontend_spring2023/views/help_pages/pantry_help_page.dart';
import 'package:realm/realm.dart';
import 'package:kitsain_frontend_spring2023/database/pantry_proxy.dart';
import 'package:kitsain_frontend_spring2023/assets/itembuilder.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/categories.dart';
import 'package:kitsain_frontend_spring2023/controller/tasklist_controller.dart';
import 'package:kitsain_frontend_spring2023/controller/task_controller.dart';
import 'package:intl/intl.dart';

// This file only sets the general UI: where are the show and sort buttons
// and where the main content goes. Item lists are generated in
// itembuilder.dart, depending on the user's chosen options

// const double HEADERSIZE = 23.0;

class PantryView extends StatefulWidget {
  const PantryView({super.key});

  @override
  State<PantryView> createState() => _PantryViewState();
}

class _PantryViewState extends State<PantryView> {
  @override
  void initState() {
    super.initState();
    getPantryTasks();
  }
  // Default values for what the user sees: all items in alphabetical order
  final _taskListController = Get.put(TaskListController());
  final _taskController = Get.put(TaskController());
  final _pantryProxy = PantryProxy();
  String selectedView = "all";
  String selectedSort = "az";

  // List<String> categories = <String>[
  //   'New',
  //   'Meat',
  //   'Seafood',
  //   'Fruit',
  //   'Vegetables',
  //   'Frozen',
  //   'Drinks',
  //   'Bread',
  //   'Sweets',
  //   'Dairy',
  //   'Ready meals',
  //   'Dry & canned goods',
  //   'Other'
  // ];

  // Choose what items to query from db based on user selection
  RealmResults<Item>? chosenStream(String selectedView) {
    if (selectedView == "all" || selectedView == "bycat") {
      print("items: ${_pantryProxy.getPantryItems(selectedSort)}");
      return PantryProxy().getPantryItems(selectedSort);
    } else if (selectedView == "opened") {
      return PantryProxy().getOpenedItems(selectedSort);
    } else if (selectedView == "favorites") {
      return PantryProxy().getFavouriteItems(selectedSort);
    }
    return null;
  }

  // If the category has no items, the header for it will not be shown
  bool checkIfEmpty(int cat) {
    if (PantryProxy().getCatCount(cat) > 0) {
      return true;
    } else {
      return false;
    }
  }

  void _addNewItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          child: NewItemForm(),
        );
      },
    );
  }

  void _help() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          //heightFactor: 0.7,
          child: PantryHelp(),
        );
      },
    );
  }

  createPantryTaskList() async {
    var pantryFound = await checkIfPantryListExists();
    print("pantryfound: ${pantryFound}");
    if (pantryFound == "not") {
      _taskListController.createTaskLists("My Pantry");
    }
    await getPantryTasks();
    }

  Future checkIfPantryListExists() async {
    await _taskListController.getTaskLists();
    var pantryIndex = "not";
    if (_taskListController.taskLists.value?.items != null) {
      int length = _taskListController.taskLists.value?.items!.length as int;
      for (var i = 0; i < length; i++) {
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
  bool checkIfItemInrealm(String googleTaskId, RealmResults<Item> realmItems) {
    var googleTaskIdList = realmItems.map((e) => e.googleTaskId);
    if (googleTaskIdList.contains(googleTaskId)) {
      return true;
    }
    else {
      return false;
    }
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

  savePantryTasksToRealm(index) async {
    var realmItems = await PantryProxy().getPantryItems();
    var tasks = await _taskController.getTasksList(index);
    for (var i = 0; i < tasks.items.length; i++) {
      if (!checkIfItemInrealm(tasks.items[i].id, realmItems)) {
        var item = Item(ObjectId().toString(), tasks.items[i].title, "Pantry", 1, googleTaskId: tasks.items[i].id);
        if (tasks.items[i].due != null) {
          item.expiryDate = convertToRealmDateTime(tasks.items[i].due);
        }
        item = parseDescriptionStringFromGoogleTask(tasks.items[i].notes, item);
        _pantryProxy.upsertItem(item);
      }
    }
  }

  getPantryTasks() async {
    await _taskListController.getTaskLists();
    var index = await checkIfPantryListExists();
    
    if (index == "not") {
      await createPantryTaskList();
    }
    await savePantryTasksToRealm(index);
    var realmItems = await PantryProxy().getItems();
    print(realmItems);
  }

  _receiveItem(Item data) {
    PantryProxy().changeLocation(data, "Pantry");
    setState(
      () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data.name,
              style: AppTypography.smallTitle,
            ),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  // final catEnglish = <int, String>{
  //   1: 'New',
  //   2: 'Meat',
  //   3: 'Seafood',
  //   4: 'Fruit',
  //   5: 'Vegetables',
  //   6: 'Frozen',
  //   7: 'Drinks',
  //   8: 'Bread',
  //   9: 'Treats',
  //   10: 'Dairy',
  //   11: 'Ready meals',
  //   12: 'Dry & canned goods',
  //   13: 'Other'
  // };

  // Map catFinnish = {
  //   1: 'Uudet',
  //   2: 'Liha',
  //   3: 'Merenantimet',
  //   4: 'Hedelmät',
  //   5: 'Vihannekset',
  //   6: 'Pakasteet',
  //   7: 'Juomat',
  //   8: 'Leivät',
  //   9: 'Herkut',
  //   10: 'Maitotuotteet',
  //   11: 'Valmisateriat',
  //   12: 'Kuivatuotteet',
  //   13: 'Muut'
  // };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main2,
      appBar: TopBar(
        title: AppLocalizations.of(context)!.pantryScreen,
        addFunction: _addNewItem,
        helpFunction: _help,
        backgroundImageName: 'assets/images/pantry_banner_B1.jpg',
        titleBackgroundColor: AppColors.titleBackgroundBrown,
      ),
      body: DragTarget<Item>(
        onAccept: (data) => _receiveItem(data),
        builder: (context, candidateData, rejectedData) {
          return ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton(
                    initialValue: selectedView,
                    onSelected: (value) {
                      setState(
                        () {
                          selectedView = value.toString();
                        },
                      );
                    },
                    child: const Icon(
                      Icons.tune,
                      size: 30,
                    ),
                    itemBuilder: (BuildContext context) {
                      return const [
                        PopupMenuItem(
                          value: "all",
                          child: Text(
                            "ALL",
                            style: AppTypography.smallTitle,
                          ),
                        ),
                        PopupMenuItem(
                          value: "favorites",
                          child: Text(
                            "FAVORITES",
                            style: AppTypography.smallTitle,
                          ),
                        ),
                        PopupMenuItem(
                          value: "opened",
                          child: Text(
                            "OPENED",
                            style: AppTypography.smallTitle,
                          ),
                        ),
                        PopupMenuItem(
                          value: "bycat",
                          child: Text(
                            "BY CATEGORY",
                            style: AppTypography.smallTitle,
                          ),
                        ),
                      ];
                    },
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  PopupMenuButton(
                    initialValue: selectedSort,
                    onSelected: (value) {
                      setState(
                        () {
                          selectedSort = value.toString();
                        },
                      );
                    },
                    child: const Icon(
                      Icons.filter_list,
                      size: 30,
                    ),
                    itemBuilder: (BuildContext context) {
                      return const [
                        PopupMenuItem(
                          value: "az",
                          child: Text(
                            "A - Z",
                            style: AppTypography.smallTitle,
                          ),
                        ),
                        PopupMenuItem(
                          value: "expdate",
                          child: Text(
                            "Expiration date",
                            style: AppTypography.smallTitle,
                          ),
                        ),
                        PopupMenuItem(
                          value: "addedlast",
                          child: Text(
                            "Added last",
                            style: AppTypography.smallTitle,
                          ),
                        ),
                      ];
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
              StreamBuilder<RealmResultsChanges<Item>>(
                stream: chosenStream(selectedView)?.changes,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  if (data == null) {
                    return const CircularProgressIndicator(); // while loading data
                  }
                  final results = data.results;
                  if (results.isEmpty) {
                    
                    return const Center(
                      child: Text(
                        "No items found",
                        style: AppTypography.smallTitle,
                      ),
                    );
                  } else {
                    if (selectedView == "all") {
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
                          ItemBuilder(
                            items: results,
                            sortMethod: selectedSort,
                            loc: "Pantry",
                          ),
                        ],
                      );
                    }
                    if (selectedView == "favorites") {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                            child: Text(
                              "FAVORITE ITEMS",
                              style: AppTypography.heading3,
                            ),
                          ),
                          ItemBuilder(
                            items: results,
                            sortMethod: selectedSort,
                            loc: "Pantry",
                          ),
                        ],
                      );
                    }
                    if (selectedView == "opened") {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                            child: Text(
                              "OPENED ITEMS",
                              style: AppTypography.heading3,
                            ),
                          ),
                          ItemBuilder(
                            items: results,
                            sortMethod: selectedSort,
                            loc: "Pantry",
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          for (var cat in Categories.categoriesByIndex.keys)
                            if (checkIfEmpty(cat))
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                    child: Text(
                                      Categories.categoriesByIndex[cat]!
                                          .toUpperCase(),
                                      style: AppTypography.heading3,
                                    ),
                                  ),
                                  ItemBuilder(
                                    items: PantryProxy()
                                        .getByMainCat(cat, selectedSort),
                                    sortMethod: selectedSort,
                                    loc: "Pantry",
                                  ),
                                  const Divider(
                                    height: 15,
                                    indent: 20,
                                    endIndent: 20,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                        ],
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
