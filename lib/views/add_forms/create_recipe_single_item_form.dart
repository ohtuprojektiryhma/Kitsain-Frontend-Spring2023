import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/database/openaibackend.dart';

class CreateRecipeSingleItemForm extends StatefulWidget {
  const CreateRecipeSingleItemForm({super.key});

  @override
  _CreateRecipeSingleItemFormState createState() =>
      _CreateRecipeSingleItemFormState();
}

class _CreateRecipeSingleItemFormState extends State<CreateRecipeSingleItemForm> {
  final _formKey = GlobalKey<FormState>();
  String _ingredient = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Ingredient',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter an ingredient';
              }
              return null;
            },
            onSaved: (value) {
              _ingredient = value!;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                CreateSingleItemRecipeLogic.submitIngredient(_ingredient);
                print('Submitted ingredient: $_ingredient');
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class CreateSingleItemRecipeLogic {
  static void submitIngredient (String ingredient) async {
    var recipe = await generateSingleItemRecipe(ingredient);
    print('Generated recipe: $recipe');
    print('Submitted ingredient: $ingredient');
  }
}