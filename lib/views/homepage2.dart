import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:get/get.dart';
import 'package:googleapis/tasks/v1.dart';
import 'package:kitsain_frontend_spring2023/controller/tasklist_controller.dart';
import 'package:kitsain_frontend_spring2023/LoginController.dart';
import 'package:kitsain_frontend_spring2023/main.dart';

class HomePage2 extends StatelessWidget {
  HomePage2({super.key});

  final loginController = Get.put(LoginController());
  final taskListController = Get.put(TaskListController());

  var username = 'Test';

  TaskList taskList1 = TaskList(title: 'testtle');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * .8,
          width: MediaQuery.of(context).size.width * .8,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 5),
            borderRadius: BorderRadius.all(Radius.circular(35)),
          ),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .05,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      child: Image.asset(
                        "assets/images/sign_in.jpg",
                        height: MediaQuery.of(context).size.height * .6,
                        fit: BoxFit.cover,
                        isAntiAlias: true,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    child: Text(
                      'WELCOME\nTO\nKITSAIN!',
                      style: TextStyle(
                        fontSize: 44,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SignInButton(
                Buttons.Google,
                shape: RoundedRectangleBorder(
                    side: new BorderSide(color: Colors.white),
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(10))),
                onPressed: () async {
                  await loginController.googleLogin();
                  await taskListController.getTaskLists();

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: ((context) => HomePage(
                            title: 'Kitsain MVP Spring 2023',
                          ))));

                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: ((context) => TaskListsScreen())));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
