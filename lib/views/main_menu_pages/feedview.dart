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

class _FeedViewState extends State<FeedView> {
  List<Post> posts = []; // Create an empty list to store the posts

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main2,
      appBar: TopBar(
        title: AppLocalizations.of(context)!.feedScreen,
        helpFunction: _help,
        backgroundImageName: 'assets/images/pantry_banner_B1.jpg',
        titleBackgroundColor: AppColors.titleBackgroundBrown,
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(post: posts[index]);
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
                posts.insert(0, newPost);
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

  const PostCard({Key? key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey, // Change the card color here
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
                    // Handle popup menu item selection
                    if (value == 'remove') {
                      // Edit button logic here
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
            const SizedBox(height: 8),
            Text(
              post.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.thumb_up),
                const SizedBox(width: 4),
                Text(post.likes.toString()),
                const SizedBox(width: 16),
                const Icon(Icons.comment),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
