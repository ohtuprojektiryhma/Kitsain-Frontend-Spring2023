import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/LoginController.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/assets/top_bar.dart';
import 'package:kitsain_frontend_spring2023/models/comment.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:kitsain_frontend_spring2023/services/auth_service.dart';
import 'package:kitsain_frontend_spring2023/views/createPost/create_post_view.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/feed/comment_section_view.dart';
import 'package:kitsain_frontend_spring2023/views/help_pages/pantry_help_page.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:kitsain_frontend_spring2023/views/createPost/create_edit_post_view.dart';

import 'feed_image_widget.dart';

class FeedView extends StatefulWidget {
  const FeedView({Key? key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView>
    with AutomaticKeepAliveClientMixin {
  var postProvider = PostProvider();

  @override
  bool get wantKeepAlive => true;

  void _help() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          //heightFactor: 0.7,
          child: PantryHelp(),
        );
      },
    );
  }

  void removePost(Post post) {
    setState(() {
      postProvider.deletePost(post);
    });
  }

  void editPost(Post post) {
    setState(() {
      postProvider.updatePost(post);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.main2,
      appBar: TopBar(
        title: AppLocalizations.of(context)!.feedScreen,
        helpFunction: _help,
        backgroundImageName: 'assets/images/pantry_banner_B1.jpg',
        titleBackgroundColor: AppColors.titleBackgroundBrown,
      ),
      body: ListView.builder(
        itemCount: postProvider.posts.length,
        itemBuilder: (context, index) {
          return PostCard(
            post: postProvider.posts[index],
            onRemovePost: (Post removedPost) {
              removePost(removedPost);
            },
            onEditPost: (Post updatedPost) {
              editPost(updatedPost);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostView()),
          ).then((newPost) {
            if (newPost != null) {
              setState(() {
                postProvider.addPost(newPost);
              });
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

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

  void _editPost(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEditPostView(post: post),
      ),
    ).then((updatedPost) {
      if (updatedPost != null) {
        widget.onEditPost(updatedPost); // Pass the updated post back
      }
    });
  }

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
              ],
            ),
            // Add image holder here
            feedImageWidget(images: widget.post.images),
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
                      setState(() {
                        widget.post.addUsefulcount(
                            loginController.googleUser.value!.id);
                      });
                    },
                  ),
                  Text(widget.post.useful.length.toString()),
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
                            return const CommentSectionView(comments: []);
                          } else {
                            return CommentSectionView(comments: comments);
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
