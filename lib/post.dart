import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
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

  String image = "IMAGE_HERE";
  String title = "TITLE_HERE";
  String description = "EMPTY_DESC";
  int likes = 0;
  List<String> comments = [];
  Item item = Item("null","null","null",0);

  Post(this.image,
      this.title,
      this.description,
      this.likes,
      this.comments,
      this.item);
}