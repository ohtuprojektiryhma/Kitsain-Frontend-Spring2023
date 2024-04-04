import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/shopping_lists.dart';

class ShoppingListNavigation extends StatefulWidget {
  const ShoppingListNavigation({super.key});

  @override
  State<ShoppingListNavigation> createState() => _ShoppingListNavigationState();
}

class _ShoppingListNavigationState extends State<ShoppingListNavigation> {

  setActiveShoppingListIndex(index) {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
          pages: [
            MaterialPage(
                child: ShoppingLists(
                    setActiveShoppingListIndex: setActiveShoppingListIndex)),
            // if (_activeList != '')
            //   MaterialPage(
            //       child: UserShoppingList(
            //     taskListIndex: _activeShoppingListIndex,
            //   )),
          ],
          onPopPage: (route, result) {
            return route.didPop(result);
          }),
    );
  }
}
