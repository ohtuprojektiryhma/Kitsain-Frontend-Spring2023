import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/assets/top_bar.dart';
import 'package:kitsain_frontend_spring2023/post.dart';
import 'package:kitsain_frontend_spring2023/views/help_pages/pantry_help_page.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/create_post_view.dart';

class FeedView extends StatefulWidget {
  const FeedView({Key? key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView>
    with AutomaticKeepAliveClientMixin {
  // postProvider is a reference to the PostProvider class to manage posts
  var postProvider = PostProvider();

  @override
  // Keep the state of the widget when switching between tabs
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

  /// Removes a post from the feed.
  void removePost(Post post) {
    setState(() {
      postProvider.deletePost(post);
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostView()),
          ).then((newPost) {
            // Update the feed with the new post
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

/// A card widget that represents a post.
///
/// This widget displays the title, content, likes, and comments of a post.
class PostCard extends StatelessWidget {
  final Post post;

  final Function(Post) onRemovePost;

  const PostCard({Key? key, required this.post, required this.onRemovePost})
      : super(key: key);

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
                  post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz),
                  onSelected: (value) {
                    // Handle popup menu item selection and logic
                    if (value == 'remove') {
                      _removeConfirmation(context);
                    } else if (value == 'edit') {
                      // Edit button logic here
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
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey[300],
              child: Image.file(post.image, fit: BoxFit.cover
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expiring date: ${DateFormat('dd.MM.yyyy').format(post.expiringDate)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Price: ${post.price}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                post.description,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.thumb_up),
                  const SizedBox(width: 4),
                  Text(post.likes.toString()),
                  const SizedBox(width: 16),
                  const Icon(Icons.comment),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                onRemovePost(post);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
