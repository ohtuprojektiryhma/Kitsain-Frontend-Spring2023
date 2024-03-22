import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:http/http.dart' as http;
import 'package:kitsain_frontend_spring2023/services/auth_service.dart';
import 'package:logger/logger.dart';

/// A service class for managing posts.
class PostService {
  final accessToken = Get.put(AuthService()).accessToken;
  var logger = Logger(printer: PrettyPrinter());

  // Base URL for the API
  final String baseUrl = 'http://nocng.id.vn:9090/api/v1/posts';

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
  /// This method takes a [Post] object as a parameter and sends a POST request to the server to create a new post.
  /// It returns the created [Post] object if the request is successful, otherwise it returns null.
  Future<Post?> createPost(Post post) async {
    // Format the expiration date of the post
    String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        .format(post.expiringDate.toUtc());

    // Upload the images associated with the post and get their filenames
    List<String> filenames = await uploadFiles(post.images);

    try {
      // Send a POST request to the server with the post data
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer ${accessToken.value}',
        },
        body: jsonEncode({
          'title': post.title,
          'description': post.description,
          'price': post.price,
          'images': filenames,
          'expringDate': formattedDate,
        }),
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, print a success message
        logger.i("Post created successfully");
      } else {
        // Handle other status codes if needed
        logger.e('Request failed with status: ${response.statusCode}');
        // logger.e(response.body);
      }
    } catch (error) {
      // Print the error message if an error occurs during the request
      logger.e("ERROR: $error");
      // Handle any errors that occur during the request
    }
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

  /// Uploads multiple files to the server.
  ///
  /// Takes a list of [File] objects as input and returns a list of [String] filenames.
  /// Returns an empty list if the upload fails.
  Future<List<String>> uploadFiles(List<File> files) async {
    try {
      // Create a list of MultipartFile objects
      List<http.MultipartFile> multipartFiles = [];
      for (File file in files) {
        String fileName = file.path.split('/').last;
        multipartFiles.add(await http.MultipartFile.fromPath('files', file.path,
            filename: fileName));
      }

      // Create a multipart request
      var request = http.MultipartRequest('POST',
          Uri.parse('http://nocng.id.vn:9090/api/v1/files/upload/files'));

      // Add the files to the request
      request.files.addAll(multipartFiles);
      request.headers.addAll({
        'accept': '*/*',
        'Authorization': 'Bearer ${accessToken.value}',
      });

      // Send the request
      var streamedResponse = await request.send();

      // Convert the streamedResponse into a response
      var response = await http.Response.fromStream(streamedResponse);

      // Handle response from the backend
      if (response.statusCode == 200) {
        logger.i("Files uploaded successfully");
        List<Map<String, dynamic>> files =
            (jsonDecode(response.body) as List<dynamic>)
                .cast<Map<String, dynamic>>();
        List<String> filenames =
            files.map((file) => file['filename']).cast<String>().toList();
        return filenames;
      } else {
        // Error handling
        logger.e('Failed to upload files. Status code: ${response.statusCode}');
        // logger.e(response.body);
        return [];
      }
    } catch (e) {
      // Error handling
      logger.e('Error uploading files: $e');
      return [];
    }
  }
}
