import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:http/http.dart' as http;
import 'package:kitsain_frontend_spring2023/services/auth_service.dart';

/// A service class for managing posts.
class PostService {
  final AuthService authService = AuthService();

  // Base URL for the API
  final String baseUrl = 'http://nocng.id.vn:9090/api/v1/posts';

  // Token for bearer authentication
  final accessToken = AuthService().accessToken;

  /// Retrieves a list of all posts.
  ///
  /// Returns a list of [Post] objects.
  Future<List<Post>> getPosts() async {
    // Logic to get all the posts
    return [];
  }

  /// Retrieves a post by its ID.
  ///
  /// Returns a [Post] object if found, otherwise returns null.
  Future<Post?> getPost(int id) async {
    // Logic to get a post by id
    return null;
  }

  /// Creates a new post.
  ///
  /// Returns the created [Post] object if successful, otherwise returns null.
  Future<Post?> createPost(Post post) async {
    // Logic to create the post
    return null;
  }

  /// Updates an existing post.
  ///
  /// Returns the updated [Post] object if successful, otherwise returns null.
  Future<Post?> updatePost(Post post) async {
    // Logic to update the post
    return null;
  }

  /// Deletes a post by its ID.
  ///
  /// Throws an exception if the deletion fails.
  Future<void> deletePost(int id) async {
    // Logic to delete the post
  }
}
