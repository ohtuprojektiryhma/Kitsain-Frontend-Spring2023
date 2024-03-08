import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/models/comment.dart';

/// TODO:
/// - Connect user information to comment box; an identifier
///   for unique users.
/// - ListView always displays the topmost item

/// Class for creating the comment section view.
class CommentSectionView extends StatefulWidget {
  final List<Comment> comments;

  const CommentSectionView({super.key, required this.comments});

  @override
  State<CommentSectionView> createState() => _CommentSectionViewState();
}

class _CommentSectionViewState extends State<CommentSectionView> {
  List<Comment> _tempComments = [];
  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempComments = List.of(widget.comments);
  }

  /// Comment object for storing info about
  /// current instance of comment.
  Comment _createCommentObj(String author, String message, DateTime date) {
    return Comment(author: author, message: message, date: date);
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
        reverse: true,
        shrinkWrap: true,
        itemCount: _tempComments.length,
        itemBuilder: (context, index) {
          return CommentBox(
            comment: _tempComments[index].message,
            index: index + 1,
            date: _tempComments[index].date,
          );
        },
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textFieldController,
                decoration: const InputDecoration(labelText: 'New comment...'),
              ),
            ),
            IconButton(
                onPressed: () {
                  String message = _textFieldController.text;
                  Comment myComment = _createCommentObj(
                      "user", _textFieldController.text, DateTime.now());
                  if (message != '') {
                    setState(() {
                      _tempComments.add(myComment);
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
    _textFieldController.dispose();
    super.dispose();
  }
}

/// Class for individual comment boxes.
class CommentBox extends StatelessWidget {
  final DateTime date;
  final String comment;
  final int index;

  const CommentBox(
      {super.key,
      required this.comment,
      required this.index,
      required this.date});

  /// Converts the time into a pretty string.
  String _timeToString(DateTime t) {
    /**
     * TODO: ideas
     * - Make time and date display smarter. For example:
     *   > If comment was posted today -> display 'today' on date
     *   > If comment was posted within 7 days -> display eg. 3 days ago
     *   > If time was under 1 minute ago -> displau 'just now'
     *   > If time was under 1 hour ago -> display minutes
     *   > If time was over 1 hour ago -> display hours
     */
    return '${t.year}.${t.month}.${t.day}   ${t.hour}:${t.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onLongPress: () {/*TODO: press to delete logic*/},
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
                      Text('${_timeToString(date)}'),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Align(alignment: Alignment.centerLeft, child: Text(comment)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
