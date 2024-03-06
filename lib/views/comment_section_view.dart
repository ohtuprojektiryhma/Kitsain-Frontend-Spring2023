import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/forms/v1.dart';
import 'package:kitsain_frontend_spring2023/post.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/feedview.dart';
import 'package:flutter/services.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:path/path.dart';

/// Class for creating the comment section view.
class CommentSectionView extends StatefulWidget {
  final List<String> comments;

  const CommentSectionView({super.key, required this.comments});

  @override
  State<CommentSectionView> createState() => _CommentSectionViewState();
}

class _CommentSectionViewState extends State<CommentSectionView> {
  String _myComment = 'null';
  List<String> _tempComments = [];
  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tempComments = List.of(widget.comments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _tempComments);
          },
        ),
      ),
      body: ListView.builder(
          itemCount: _tempComments.length,
          itemBuilder: (context, index) {
          return CommentBox(
              comment: _tempComments[index],
              index: index + 1,);
        },
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.fromLTRB(10,0,10,10),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textFieldController,
                decoration: const InputDecoration(
                    labelText: 'New comment...'
                ),
                onChanged: (value) {
                  setState(() {_myComment = value;});
                },
              ),
            ),
            IconButton(
                onPressed: (){
                  if (_myComment != ''){
                    setState(() {
                      _tempComments.add(_myComment);
                    });
                    _textFieldController.clear();
                  }
                },
                icon: const Icon(Icons.send))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _textFieldController.dispose();
    super.dispose();
  }
}

/// Class for individual comment boxes.
class CommentBox extends StatelessWidget {

  final String comment;
  final int index;

  const CommentBox({super.key, required this.comment, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onLongPress: (){/*TODO: press to delete logic*/},
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 100),
          child: Container(
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(),
                      const Icon(Icons.person),
                      Text('$index'), // This part could display username
                      const SizedBox(width: 30),
                      const Text('Date'),
                      const SizedBox(width: 10),
                      const Text('Time'),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(comment)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
