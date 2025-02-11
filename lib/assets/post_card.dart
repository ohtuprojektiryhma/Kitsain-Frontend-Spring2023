import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/login_controller.dart';
import 'package:kitsain_frontend_spring2023/models/comment.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:kitsain_frontend_spring2023/services/auth_service.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/feed/comment_section_view.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/feed/create_edit_post_view.dart';
import 'package:kitsain_frontend_spring2023/services/comment_service.dart';
import 'package:logger/logger.dart';

import 'image_carousel.dart';

/// A card widget that displays a post.
class PostCard extends StatefulWidget {
  final Post post;
  final Function(Post) onRemovePost;
  final Function(Post) onEditPost;

  const PostCard({
    Key? key,
    required this.post,
    required this.onRemovePost,
    required this.onEditPost,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // Variable to hold the current user
  final loginController = Get.put(LoginController());
  final authService = Get.put(AuthService());
  var logger = Logger(printer: PrettyPrinter());
  final postService = PostService();
  final CommentService commentService = CommentService();
  late String userId;
  bool isOwner = false;

  @override
  void initState() {
    super.initState();
    fetchUserId();
    //loadComments();
  }

  Future<void> fetchUserId() async {
    final fetchedUserId = await postService.getUserId();
    setState(() {
      userId = fetchedUserId;
      isOwner = widget.post.userId == userId;
    });
  }

  Future<void> markPostUseful() async {
    await postService.markPostUseful(widget.post.id);
    Post? updatedPost = await postService.getPostById(widget.post.id);
    setState(() {
      if (updatedPost != null) widget.post.useful = updatedPost.useful;
    });
  }

  /// Edits a post.
  void _editPost(Post post) async {
// Navigate to the CreateEditPostView and wait for the result
    final updatedPost = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CreateEditPostView(post: post, existingImages: post.images)),
    );

    // Check if the updatedPost is not null
    if (updatedPost != null) {
      // Pass the updated post back to the FeedView
      widget.onEditPost(updatedPost);
    }
  }

  /// Shows a confirmation dialog before removing a post.
  void _removeConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Post'),
          content: const Text('Are you sure you want to remove this post?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Call the removePost method from FeedView
                widget.onRemovePost(widget.post);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 206, 205, 205),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (isOwner)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (value) {
                      if (value == 'remove') {
                        _removeConfirmation(context);
                      } else if (value == 'edit') {
                        _editPost(widget.post);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'remove',
                        child: Text('Remove'),
                      ),
                    ],
                  ),
                if (!isOwner)
                  const SizedBox(
                    height: 40,
                  ),
              ],
            ),

            // Check if there are images to display
            // Add image holder here
            if (widget.post.images.isNotEmpty)
              editImageWidget(
                  images: const [],
                  stringImages: widget.post.images,
                  feedImages: true),

            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expiring date: ${DateFormat('dd.MM.yyyy').format(widget.post.expiringDate)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Price: ${widget.post.price}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                widget.post.description,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up_alt_outlined),
                    onPressed: () {
                      markPostUseful();
                    },
                  ),
                  Text(widget.post.useful.toString()),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.comment_rounded),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          List<Comment> comments =
                              widget.post.comments.cast<Comment>();
                          if (comments.isEmpty) {
                            return CommentSectionView(
                                parentID: widget.post.id, comments: const []);
                          } else {
                            return CommentSectionView(
                                parentID: widget.post.id, comments: comments);
                          }
                        }),
                      ).then((updatedComments) {
                        setState(() {
                          widget.post.comments = updatedComments;
                        });
                      });
                    },
                  ),
                  Text(widget.post.comments.length.toString())
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
