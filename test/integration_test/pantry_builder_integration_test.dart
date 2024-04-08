import 'package:flutter_test/flutter_test.dart';
import 'package:kitsain_frontend_spring2023/assets/pantry_builder_recipe_generation.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:mockito/mockito.dart';
import 'package:realm/realm.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
class MockRealmResults<T> extends Mock implements RealmResults<T> {
  List<T> items;

  MockRealmResults(this.items);

  @override
  int get length => items.length;

  @override
  Iterator<T> get iterator => items.iterator;


  @override
  T operator [](int index) {
    if (index >= 0 && index < items.length) {
      return items[index];
    }
    throw Exception('Index out of range: $index');
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late MockRealmResults<Item> mockRealmResults;
  late List<Item> mockItems;
  late List thisMustHaveItems;
  late List thisOptionalItems;
  late Widget widget;

  group('end-to-end test', () {
    setUp(() {
      mockItems = <Item>[
        Item(ObjectId().toString(), "Apple", "Pantry", 3),
        Item(ObjectId().toString(), "Banana", "Pantry", 3)
      ];
      mockRealmResults = MockRealmResults<Item>(mockItems);
      thisMustHaveItems = <String>[];
      thisOptionalItems = <String>[];
      widget = PantryBuilderTestWrapper(
        sortMethod: "az",
        items: mockRealmResults,
        onMustHaveItemsChanged: (mustHaveItems) {
          thisMustHaveItems = mustHaveItems;
        },
        onOptionalItemsChanged: (optionalItems) {
          thisOptionalItems = optionalItems;
        },
      );
    });

    testWidgets('When adding pantry items to the ingredient list for recipe they are put into the optional items list at first',
        (tester) async {
      // Load app widget with the mocked RealmResults

      await tester.pumpWidget(widget);
  
      
      await tester.pumpAndSettle(); // Wait for animations to complete
      expect(find.text(mockItems[0].name), findsOneWidget);
      await tester.tap(find.text(mockItems[0].name)); // Tap on the first item on rest on the list
      await tester.pumpAndSettle(); // Wait for animations to complete

      // Verify that the item is moved to the appropriate list
      expect(thisMustHaveItems.contains(mockItems[0].name), false);
      expect(thisOptionalItems.contains(mockItems[0].name), true);
    });

    // testWidgets("", (widgetTester) => null)
  });
}

class PantryBuilderTestWrapper extends StatelessWidget {
  final RealmResults<Item> items;
  final String sortMethod;
  final Function(List<String>) onOptionalItemsChanged;
  final Function(List<String>) onMustHaveItemsChanged;

  const PantryBuilderTestWrapper({
    super.key,
    required this.sortMethod,
    required this.items,
    required this.onOptionalItemsChanged,
    required this.onMustHaveItemsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PantryBuilder(
        items: items,
        sortMethod: sortMethod,
        onMustHaveItemsChanged: onMustHaveItemsChanged,
        onOptionalItemsChanged: onOptionalItemsChanged,
      ),
    );
  }
}
