import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';

const List<List<String>> paragraphs = [
  [
    'In "My Recipes" you can view your recipes.',
    'Click the recipe to delete or edit. Kitsain recipes',
    'are connected to Google Tasks so you can',
    'so you can access them easily outside the app.',
  ],
  [
    'You can create a new recipes by clicking the ',
    'plus-icon. You can give the recipe generator',
    'some backround information for a perfect recipe!',
  ],
  [
    'Kitsain uses AI to generate the recipe and is not',
    'responsible for the safety of the recipe.'
  ],
];

class RecipeHelp extends StatefulWidget {
  const RecipeHelp({super.key});

  @override
  State<RecipeHelp> createState() => _RecipeHelp();
}

class _RecipeHelp extends State<RecipeHelp> {
  //Helper function for creating texts and icons.
  //Returns text and icon widgets.
  Widget _createParagraph(List<String> paragraph, bool icons) {
    List<Widget> list = <Widget>[];
    for (var line in paragraph) {
      list.add(Text(line, style: AppTypography.paragraph));
      //After last row don't add empty space
      if (line != paragraph[paragraph.length - 1]) {
        list.add(SizedBox(height: 3));
      }
    }

    return new Column(children: list);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        backgroundColor: AppColors.main2,
        body: ListView(children: <Widget>[
          Column(
            children: [
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: FloatingActionButton(
                        foregroundColor: AppColors.main2,
                        backgroundColor: AppColors.main3,
                        child: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text(
                "WHAT'S IN\nMY RECIPES?",
                style: AppTypography.heading2.copyWith(color: AppColors.main3),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              _createParagraph(paragraphs[0], true),
              SizedBox(height: 20),
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/delete_or_edit.png"),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _createParagraph(paragraphs[1], true),
              SizedBox(height: 20),
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/create_recipe.png"),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _createParagraph(paragraphs[2], true),
              SizedBox(height: 50),
              SizedBox(
                width: 100,
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.resolveWith(
                        (states) => AppColors.main2),
                    backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => AppColors.main3),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "GOT IT",
                    style: AppTypography.category,
                  ),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ]),
      );
    });
  }
}
