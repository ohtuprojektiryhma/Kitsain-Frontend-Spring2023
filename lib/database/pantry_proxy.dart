import 'package:realm/realm.dart';
import 'package:flutter/foundation.dart';
import 'item.dart';

// This file is used to modify the database.
// When you want to call a function from another class,
// use for example PantryProxy().

var _config =
    Configuration.local([Item.schema], shouldDeleteIfMigrationNeeded: true);
var realm = Realm(_config);

class PantryProxy with ChangeNotifier {
  RealmResults<Item> getItems() {
    var all = realm.all<Item>();
    return all;
  }

  subscribe() {
    final items = getItems();
    items.changes.listen((changes) {
      changes.inserted; // indexes of inserted objects
      changes.modified; // indexes of modified objects
      changes.deleted; // indexes of deleted objects
      changes.newModified; // indexes of modified objects
      // after deletions and insertions are accounted for
      changes.moved; // indexes of moved objects
      changes.results; // the full List of objects
    });
  }

  RealmResults<Item> getPantryItems([String sortBy = "az"]) {
    var all = getItems();
    late RealmResults<Item> result;
    // var result = all.query("location == \$0", ["Pantry"]);
    if (sortBy == "az") {
      result = all.query("location = \$0 SORT(name ASC)", ["Pantry"]);
    } else if (sortBy == "expdate") {
      result = all.query("location = \$0 SORT(expiryDate ASC)", ["Pantry"]);
    } else if (sortBy == "addedLast") {
      result = all.query("location = \$0 SORT(addedDate ASC)", ["Pantry"]);
    }

    return result;
  }

  RealmResults<Item> getOpenedItems([String sortBy = "az"]) {
    var pantryitems = getPantryItems();
    //var result = all.query("location == \$0", ["Pantry"]);
    var result = pantryitems.query(
      "openedDate != null",
    );
    late RealmResults<Item> sorted;
    if (sortBy == "az") {
      sorted = result.query("location = \$0 SORT(name ASC)", ["Pantry"]);
    } else if (sortBy == "expdate") {
      sorted = result.query("location = \$0 SORT(expiryDate ASC)", ["Pantry"]);
    } else if (sortBy == "addedLast") {
      sorted = result.query("location = \$0 SORT(addedDate ASC)", ["Pantry"]);
    }

    return sorted;
  }

  RealmResults<Item> getUsedItems() {
    var all = getItems();
    var result = all.query("location == \$0", ["Used"]);
    return result;
  }

  RealmResults<Item> getBinItems() {
    var all = getItems();
    var result = all.query("location == \$0", ["Bin"]);
    return result;
  }

  int getCatCount(String category) {
    var count = getPantryItems().query("mainCat == \$0", [category]).length;
    return count;
  }

  RealmResults<Item> getByMainCat(String category) {
    var pantryitems = getPantryItems();
    var result =
        pantryitems.query("mainCat == \$0 SORT(name DESC)", [category]);
    return result;
  }

  bool upsertItem(Item item) {
    debugPrint("addItem");
    try {
      debugPrint(item.mainCat);
      realm.write(() {
        realm.add<Item>(item, update: true);
      });
      notifyListeners();
      return true;
    } on RealmException catch (e) {
      debugPrint(e.message);
      return false;
    }
  }

  bool toggleItemEveryday(Item item) {
    try {
      realm.write(() {
        if (item.everyday == false) {
          item.everyday = true;
        } else {
          item.everyday = false;
        }
      });
      notifyListeners();
      return true;
    } on RealmException catch (e) {
      debugPrint(e.message);
      return false;
    }
  }

  void changeLocation(Item item, String newLoc) {
    realm.write(() {
      item.location = newLoc;
    });
    notifyListeners();
  }

  void deleteItem(Item item) {
    debugPrint("deleteItem");
    try {
      realm.write(() {
        realm.delete(item);
      });
      debugPrint("Item deleted");
      notifyListeners();
    } on RealmException catch (e) {
      debugPrint(e.message);
    }
  }

  void deleteAll() {
    realm.write(() {
      realm.deleteAll<Item>();
    });
    notifyListeners();
  }
}
