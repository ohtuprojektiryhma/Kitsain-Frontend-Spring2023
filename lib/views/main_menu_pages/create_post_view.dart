import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/post.dart';

/// A view for creating a new post.
///
/// This view allows the user to enter a title and an image for the post.
/// Once the user clicks the "Create" button, the post will be created.
class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  CreatePostViewState createState() => CreatePostViewState();
}

/// The state of the [CreatePostView] widget.
///
/// This state manages the title, image, price, and selected date for the post.
class CreatePostViewState extends State<CreatePostView> {
  // Content variables for the content of the post
  File? _image;
  String _title = '';
  String _description = '';
  String _price = '';
  DateTime _expiringDate = DateTime.now();

  // Date variables for the expiration date of the post
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  final TextEditingController _dateController = TextEditingController();

  /// Function for taking an image with camera.
  Future<void> _pickImageFromCamera() async {
    try{
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => _image = imageTemporary);
    } on PlatformException catch (e) {
      print('Failed to pick Image: $e');
    }
  }

  /// Function for selecting a picture from gallery.
  Future<void> _pickImageFromGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => _image = imageTemporary);
    } on PlatformException catch (e) {
      print('Failed to pick Image: $e');
    }
    // Add logic to select image from gallery
  }

  /// Function to select the expiration date of the post
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiringDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _expiringDate) {
      setState(() {
        _expiringDate = picked;
        _dateController.text = _dateFormat.format(_expiringDate);
      });
    }
  }

  Post _createPost() {
    // Create a Post object using the entered data
    return Post(
      _image,
      _title,
      _description,
      _price,
      _expiringDate,
    );

    // Add logic to save the post or perform any other actions
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = _dateFormat.format(_expiringDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              _image != null
                  ? Image.file(
                      _image!,
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey,
                    ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickImageFromCamera(),
                      child: Text('Camera'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => _pickImageFromGallery(),
                      child: Text('Gallery'),
                    ),
                  ],
                ),
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                onChanged: (value) {
                  setState(() {
                    _title = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Price',
                ),
                onChanged: (value) {
                  setState(() {
                    _price = value;
                  });
                },
              ),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Select expiring date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Post newPost = _createPost();
                  Navigator.pop(context, newPost);
                },
                child: Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
