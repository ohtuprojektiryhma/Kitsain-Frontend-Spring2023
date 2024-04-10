import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';
import 'package:kitsain_frontend_spring2023/database/pantry_proxy.dart';
import 'package:kitsain_frontend_spring2023/database/openaibackend.dart';
import 'dart:async';
import 'package:kitsain_frontend_spring2023/assets/pantry_builder_recipe_generation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kitsain_frontend_spring2023/controller/recipe_controller.dart';
import 'package:kitsain_frontend_spring2023/views/add_forms/feedback_form.dart';

class CreateNewRecipeForm extends StatefulWidget {
  const CreateNewRecipeForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateNewRecipeFormState createState() => _CreateNewRecipeFormState();
}

class LoadingDialogWithTimeout extends StatefulWidget {
  const LoadingDialogWithTimeout({super.key});

  @override
  _LoadingDialogWithTimeoutState createState() =>
      _LoadingDialogWithTimeoutState();
}

class _LoadingDialogWithTimeoutState extends State<LoadingDialogWithTimeout> {
  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitWanderingCubes(color: Colors.white, size: 50),
          SizedBox(height: 16),
          Text('Creating recipe...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

/// Class that upholds the state of recipe form
@override
class _CreateNewRecipeFormState extends State<CreateNewRecipeForm> {
  final _formKey = GlobalKey<FormState>();
  final _itemName = TextEditingController();
  var _pantryItems;

  bool _isLoading = true; // Flag to track loading state
  List optionalItems = [];
  List mustHaveItems = [];
  Map<String, String> itemNamesAndAmounts = {};
  String language = "English";

  String selected = "True";

  int options = 1;

  final _recipeController = RecipeController();

  @override
  void initState() {
    super.initState();
    _loadPantryItems();
  }

  onMustHaveItemsChanged(mustHaveItems) {
    setState(() {
      this.mustHaveItems = mustHaveItems;
    });
  }

  // Load pantry items asynchronously
  Future<void> _loadPantryItems() async {
    try {
      // Call your method to get pantry items

      _pantryItems = PantryProxy().getPantryItems();
    } catch (e) {
      // Handle any potential errors
      print("Error loading pantry items: $e");
    } finally {
      // Set loading state to false after items are loaded or in case of error
      setState(() {
        _isLoading = false;
      });
    }
  }

  final TextEditingController _recipeTypeController = TextEditingController();
  final TextEditingController _suppliesController = TextEditingController();
  final TextEditingController _expSoonController = TextEditingController();

  String? _selectedOption;
  var radioValues;

  /// Dialog asking whether user wants to discard changes
  void _discardChangesDialog(bool discardForm) {
    if (discardForm || _areFormFieldsEmpty()) {
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: const Text(
            'Discard changes?',
            style: AppTypography.paragraph,
          ),
          actions: <Widget>[
            _buildDialogButton('CANCEL', Colors.black38, () {
              Navigator.pop(context);
            }),
            _buildDialogButton('DISCARD', AppColors.main1, () {
              Navigator.pop(context);
              _discardChangesDialog(true);
            }),
          ],
        ),
      );
    }
  }

  bool _areFormFieldsEmpty() {
    return _itemName.text.isEmpty &&
        _recipeTypeController.text.isEmpty &&
        _suppliesController.text.isEmpty &&
        _expSoonController.text.isEmpty;
  }

  Widget _buildDialogButton(
      String text, Color textColor, void Function() onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTypography.category.copyWith(color: textColor),
      ),
    );
  }
// Choose what items to query from db based on user selection

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    return Scaffold(
      backgroundColor: AppColors.main2,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            _buildCloseButton(),
            const FeedbackButton(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            _buildRecipeHeading(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.06),
            _buildRecipeForm(),
          ],
        ),
      ),
    );
  }

  /// Builds indicator for loading.
  ///
  /// Returns indicator.
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Builds the language choice dropdown.
  ///
  /// Returns dropdown.
  Widget _buildLanguageDropdown() {
    return DropdownButton<String>(
      value: language,
      onChanged: (String? newValue) {
        setState(() {
          language = newValue!;
        });
      },
      items: <String>['English', 'Finnish', 'Swedish']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildOptionsDropdown() {
    return DropdownButton<int>(
      value: options,
      onChanged: (int? newValue) {
        setState(() {
          options = newValue!;
        });
      },
      items: <int>[1, 2, 3].map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }

  /// Builds the close button for the recipe generating form.
  ///
  /// Returns close button.
  Widget _buildCloseButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.04,
          child: FloatingActionButton(
            onPressed: () => _discardChangesDialog(false),
            foregroundColor: AppColors.main2,
            backgroundColor: AppColors.main3,
            child: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }

  /// Builds the header for the recipe generating form.
  ///
  /// Returns header.
  Widget _buildRecipeHeading() {
    return Column(
      children: [
        Text(
          'GENERATE A NEW RECIPE',
          textAlign: TextAlign.center,
          style: AppTypography.heading2.copyWith(color: AppColors.main3),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.001),
      ],
    );
  }

  /// Builds the recipe generating form as a whole.
  ///
  /// Returns recipe form.
  Widget _buildRecipeForm() {
    return Padding(
      padding: const EdgeInsets.only(left: 7, right: 7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
              'Your diet or recipe type? eg. vegan, 15-minute recipe, breakfast.',
              style: AppTypography.heading4),
          _buildTextFormField(
            controller: _recipeTypeController,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          const Text(
              'The cooking tools available/the ones you want to use for this recipe, eg. airfryer',
              style: AppTypography.heading4),
          _buildTextFormField(
            controller: _suppliesController,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          _buildDropdownMenu(),
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.15,
          ),
          const Text("Select language for the recipe:",
              style: AppTypography.heading4),
          _buildLanguageDropdown(),
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.15,
          ),
          const Text("How many recipes do you want?:",
              style: AppTypography.heading4),
          _buildOptionsDropdown(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          PantryBuilder(
              items: _pantryItems,
              sortMethod: "az",
              onMustHaveItemsChanged: (mustHaveItems) {
                setState(() {
                  this.mustHaveItems = mustHaveItems;
                });
              },
              onOptionalItemsChanged: (optionalItems) {
                setState(() {
                  this.optionalItems = optionalItems;
                });
              }),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          _buildActionButtons(),
        ],
      ),
    );
  }

  itemNamesAndAmountsConvertor(list) {
    for (var i = 0; i < list.length; i++) {
      if (list[i].contains(';')) {
        List<String> splitted = list[i].split(';');
        itemNamesAndAmounts[splitted[0]] = splitted[1];
      } else {
        itemNamesAndAmounts[list[i]] = '';
      }
    }
    return itemNamesAndAmounts;
  }

  /// Builds the text fields utilized in recipe generating form.
  ///
  /// Returns text field.
  Widget _buildTextFormField({
    required TextEditingController controller,
  }) {
    return TextFormField(
      style: AppTypography.paragraph,
      controller: controller,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
      ),
      maxLines: null,
    );
  }

  /// Builds dropdown menu determining what kind of items are allowed.
  ///
  /// Returns dropdown menu.
  Widget _buildDropdownMenu() {
    // build use only pantry/use other than pantry menu with can use other than pantry as default
    return DropdownButtonFormField<String>(
      value: _selectedOption ?? 'Can use items not in pantry',
      onChanged: (String? newValue) {
        setState(() {
          _selectedOption = newValue!;
        });
      },
      items: <String>['Use only pantry items', 'Can use items not in pantry']
          .map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        },
      ).toList(),
    );
  }

  /// Builds action buttons for the recipe form
  ///
  /// Returns buttons
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton('CANCEL', AppColors.main3, Colors.white, () {
          _discardChangesDialog(false);
        }),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.main3,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                // Use a Builder widget to create a new valid BuildContext
                return Builder(
                  builder: (BuildContext context) {
                    return _loadingDialog(context);
                  },
                );
              },
            );

            try {
              await _createRecipe();
            } finally {
              // Use rootNavigator: true to pop the dialog from the root navigator
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pop(); // Close the loading dialog
            }
          },
          child: const Text('CREATE RECIPE'),
        ),
      ],
    );
  }

  Widget _loadingDialog(BuildContext context) {
    return const LoadingDialogWithTimeout();
  }

  /// Builds template for buttons used in recipe form
  ///
  /// [label] determines the label on button, [backgroundColor] determines the background color and [textColor] determines the text color
  Widget _buildButton(String label, Color backgroundColor, Color textColor,
      Function() onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, foregroundColor: AppColors.main3),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  /// Sends the created recipe to backend
  Future<void> _createRecipe() async {
    if (_formKey.currentState!.validate()) {
      String recipeType = _recipeTypeController.text;
      String supplies = _suppliesController.text;
      bool pantryOnly = true;
      // String expSoon = _expSoonController.text;
      if (_selectedOption == "Can use items not in pantry") {
        pantryOnly = false;
      }
      Map<String, String> optionalMapped =
          itemNamesAndAmountsConvertor(optionalItems);
      Map<String, String> mustHaveMapped =
          itemNamesAndAmountsConvertor(mustHaveItems);
      var generatedRecipe = await generateRecipe(
          optionalMapped,
          recipeType,
          mustHaveMapped,
          [
            supplies
          ], // temporary solution. rather ask the user for an actual list
          pantryOnly,
          language,
          options);
      for (var recipe in generatedRecipe) {
        _recipeController.createRecipe(recipe);
      }

      // clear
      _recipeTypeController.clear();
      _suppliesController.clear();
      _expSoonController.clear();
    }
  }
}
