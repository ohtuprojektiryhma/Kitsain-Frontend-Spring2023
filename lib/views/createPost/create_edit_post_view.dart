import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:kitsain_frontend_spring2023/views/createPost/create_post_image_widget.dart';

class CreateEditPostView extends StatefulWidget {
  final Post? post;

  const CreateEditPostView({Key? key, this.post}) : super(key: key);

  @override
  _CreateEditPostViewState createState() => _CreateEditPostViewState();
}

class _CreateEditPostViewState extends State<CreateEditPostView> {
  late List<File> _images;
  late String _title;
  late String _description;
  late String _price;
  late DateTime _expiringDate;

  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _images = List.from(widget.post!.images);
      _title = widget.post!.title;
      _description = widget.post!.description;
      _price = widget.post!.price;
      _expiringDate = widget.post!.expiringDate;
      _dateController.text = _dateFormat.format(_expiringDate);
    } else {
      _images = [];
      _title = '';
      _description = '';
      _price = '';
      _expiringDate = DateTime.now();
      _dateController.text = _dateFormat.format(_expiringDate);
    }
  }

  /// Function for taking an image with camera.
  Future<void> _pickImageFromCamera() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage == null) return;

      _images.add(File(pickedImage.path));
      setState(() {});
    } on PlatformException catch (e) {
      debugPrint('Failed to pick Image: $e');
    }
  }

  /// Function for selecting a picture from gallery.
  Future<void> _pickImageFromGallery() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
          imageQuality: 100,
          maxHeight: 1000,
          maxWidth: 1000,
          source: ImageSource.gallery);

      if (pickedImage != null) {
        _images.add(File(pickedImage.path));
        debugPrint('Added image to _images list: $_images');
        setState(() {});
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick Image: $e');
    }
    // Add logic to select an image from the gallery
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

  Post _updateOrCreatePost() {
    return Post(
      _images,
      _title,
      _description,
      _price,
      _expiringDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post != null ? 'Edit Post' : 'Create Post'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              editImageWidget(images: _images),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Select Image Source'),
                          actions: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  child: Text('Camera'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _pickImageFromCamera();
                                  },
                                ),
                                SizedBox(height: 10),
                                TextButton(
                                  child: Text('Gallery'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _pickImageFromGallery();
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Add Image'),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
                onChanged: (value) {
                  setState(() {
                    _title = value;
                  });
                },
                controller: TextEditingController(text: _title),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
                controller: TextEditingController(text: _description),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
                onChanged: (value) {
                  setState(() {
                    _price = value;
                  });
                },
                controller: TextEditingController(text: _price),
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
                  Post updatedPost = _updateOrCreatePost();
                  Navigator.pop(context, updatedPost);
                },
                child: Text(widget.post != null ? 'Update' : 'Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
