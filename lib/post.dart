import 'dart:ffi';
import 'dart:io';

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

  File? image;
  String title = "TITLE_HERE";
  String description = "EMPTY_DESC";
  String price = "0";
  DateTime expiringDate = DateTime.now();
  int likes = 0;
  List<String> comments = [];
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
