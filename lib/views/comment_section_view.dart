import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:path/path.dart';

class CommentSectionView extends StatefulWidget {
  const CommentSectionView({super.key});

  @override
  State<CommentSectionView> createState() => _CommentSectionViewState();
}

class _CommentSectionViewState extends State<CommentSectionView> {
  String _myComment = "empty";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            //TODO: Display comments as a list.
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.fromLTRB(10,0,10,10),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                decoration: const InputDecoration(
                    labelText: 'New comment...'),
                cursorColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    _myComment = value;
                  });
                },
              ),
            ),
            IconButton(
                onPressed: (){

                },
                icon: Icon(Icons.send))
          ],
        ),
      ),
    );
  }
}
