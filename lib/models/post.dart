import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/models/comment.dart';

/// A class for an object that handles information about a post
/// on the social media feed tab.
///
/// Needed for storing post information locally.
class Post extends ChangeNotifier {
  /*TODO:
  *  - Functions related to likes
  *  - Functions related to comments
  *  - figure out the proper location for post.dart file
  * */

  List<String> images = [];
  String title = "TITLE_HERE";
  String description = "EMPTY_DESC";
  String price = "0";
  DateTime expiringDate = DateTime.now();
  int useful;
  List<Comment> comments = [];
  String id = "";
  String userId = "";
  //Item item;

  Post({
    required this.images,
    required this.title,
    required this.description,
    required this.price,
    required this.expiringDate,
    required this.id,
    required this.userId,
    this.useful = 0,
    this.comments = const [],
  });
  // Serialize the Post object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'expiringDate': expiringDate.toIso8601String(),
      'images': images,
    };
  }

  // Deserialize the JSON map to a Post object
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        price: json['price'],
        expiringDate: DateTime.parse(json['expiringDate']),
        images: List<String>.from(json['images']),
        userId: json['userId']);
  }
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

  /// Updates an existing post in the list of posts.
  ///
  /// The specified post is replaced with the updated post.
  void updatePost(Post updatedPost) {
    final index = _posts.indexWhere((post) => post.id == updatedPost.id);
    if (index != -1) {
      _posts[index] = updatedPost;
      notifyListeners(); // Notify listeners of the change
    }
  }
}
