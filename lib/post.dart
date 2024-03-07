import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:kitsain_frontend_spring2023/comment.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';

/// A class for an object that handles information about a post
/// on the social media feed tab.
///
/// Needed for storing post information locally.
class Post {
  /*TODO:
  *  - Functions related to likes
  *  - Functions related to comments
  *  - figure out the proper location for post.dart file
  * */

  File image;
  String title = "TITLE_HERE";
  String description = "EMPTY_DESC";
  String price = "0";
  DateTime expiringDate = DateTime.now();
  int likes = 0;
  List<Comment> comments = [];
  //Item item;

  Post(
    this.image,
    this.title,
    this.description,
    this.price,
    this.expiringDate, {
    this.likes = 0,
    this.comments = const [],
  });
}

/// A provider class for managing posts.
///
/// This class provides methods to add and delete posts.
/// It also exposes a list of posts.
class PostProvider extends ChangeNotifier {
  final List<Post> _posts = [];

  List<Post> get posts => _posts;

  /// Adds a new post to the list of posts.
  ///
  /// The new post is inserted at the beginning of the list.
  void addPost(Post newPost) {
    _posts.insert(0, newPost);
  }

  /// Deletes a post from the list of posts.
  ///
  /// The specified post is removed from the list.
  void deletePost(Post post) {
    _posts.remove(post);
  }
}
