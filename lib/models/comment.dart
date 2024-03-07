import 'package:intl/intl.dart';

/// Class for creating a comment object.
class Comment {
  String author = 'NO_AUTHOR';
  String message = 'NO_MESSAGE';
  DateTime date = DateTime.now();

  Comment({
    required this.author,
    required this.message,
    required this.date
  });
}