import 'dart:convert';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:http/http.dart' as http;
import 'package:realm/realm.dart';

// This file, as well as the Recipe class needs urgent refactoring

/// Generates a recipe using the parameters
/// [ingredients] (list of ingredients),
/// [recipeType] (the type of recipe (eg. vegan)),
/// [expSoon] (list of must have items in the recipe)
/// [supplies] (list of kitchen supplies available for use in the recipe),
/// [pantryOnly] (boolean value whether the recipe only uses items from the pantry or adds new ingredients)
/// [language] (in which language is the recipe generated in)
/// Returns a Recipe object with the generated recipe from ChatGPT
Future<Recipe> generateRecipe(
    List<String> ingredients,
    String recipeType,
    List<String> expSoon,
    List<String> supplies,
    bool pantryOnly,
    String language) async {
  var url = Uri.https(
      'kitsain-backend-test-ohtuprojekti-staging.apps.ocp-test-0.k8s.it.helsinki.fi',
      '/generate');
  var headers = {"Content-Type": "application/json"};
  var requestBody = json.encode({
    'required_items': expSoon,
    'pantry': ingredients,
    'pantry_only': pantryOnly,
    'recipe_type': recipeType,
    'special_supplies': supplies,
    'language': language
  });
  print('Request body: $requestBody');

  var response = await http.post(url, headers: headers, body: requestBody);

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  var responseMap = json.decode(response.body);

  return Recipe(ObjectId().toString(), responseMap["recipe_name"],
      selectedItems: ingredients,
      recipeType: recipeType,
      expSoon: expSoon,
      supplies: supplies,
      details: json
          .encode([responseMap["ingredients"], responseMap["instructions"]]));
}

/// Changes a recipe with the following values
/// [ingredients] (list of ingredients),
/// [recipeType] (the type of recipe (eg. vegan)),
/// [expSoon] (list of must have items in the recipe)
/// [supplies] (list of kitchen supplies available for use in the recipe),
/// [pantryOnly] (boolean value whether the recipe only uses items from the pantry or adds new ingredients)
/// Returns the new modified recipe in a Recipe object
Future<Recipe> changeRecipe(
    String? details,
    String? change,
    List<String?> ingredients,
    String? recipeType,
    List<String?> expSoon,
    List<String?> supplies,
    bool? pantryOnly) async {
  var url = Uri.https(
      'kitsain-backend-test-ohtuprojekti-staging.apps.ocp-test-0.k8s.it.helsinki.fi',
      '/change');
  var headers = {"Content-Type": "application/json"};

  // Refactor this section when the Recipe class gets correct fields.
  var extremelyHackyDetailsDecoded = json.decode(details!);
  var extremelyHackyRecipeConstruct = {
    'recipe_name': '',
    'ingredients': extremelyHackyDetailsDecoded[0],
    'instructions': extremelyHackyDetailsDecoded[1]
  };
  var requestBody =
      json.encode({'recipe': extremelyHackyRecipeConstruct, 'change': change});
  print('Request body: $requestBody');

  var response = await http.post(url, headers: headers, body: requestBody);

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  var responseMap = json.decode(response.body);

  /* The Recipe class only has these few fields so we have to hack the recipe data into those existing fields.
   * Change this when Recipe class gets more complete. */
  return Recipe(ObjectId().toString(), responseMap["recipe_name"],
      details: json
          .encode([responseMap["ingredients"], responseMap["instructions"]]));
}
