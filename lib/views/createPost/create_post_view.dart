import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';
import 'package:kitsain_frontend_spring2023/views/createPost/create_post_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

/// A view for creating a new post.
///
/// This view allows the user to enter a title and an image for the post.
/// Once the user clicks the "Create" button, the post will be created.
class CreatePostView extends StatefulWidget {
  const CreatePostView({Key? key}) : super(key: key);

  @override
  CreatePostViewState createState() => CreatePostViewState();
}

/// The state of the [CreatePostView] widget.
///
/// This state manages the title, image, price, and selected date for the post.
class CreatePostViewState extends State<CreatePostView> {
  var logger = Logger(printer: PrettyPrinter());
  final PostService _postService = PostService();
  final List<String> _images = [];
  String _title = '';
  String _description = '';
  String _price = '';
  DateTime _expiringDate = DateTime.now();
  List<File> tempImages = [];
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  final TextEditingController _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool imageSelected = true;

  /// Function for taking an image with camera.
  Future<void> _pickImageFromCamera() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage == null) return;
      tempImages.add(File(pickedImage.path));
      setState(() {
        imageSelected = tempImages.isNotEmpty;
      });
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
        source: ImageSource.gallery,
      );

      if (pickedImage != null) {
        tempImages.add(File(pickedImage.path));
        setState(() {
          imageSelected = tempImages.isNotEmpty;
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick Image: $e');
    }
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

  Future<Post?> _createPost() async {
    for (var image in tempImages) {
      _images.add(await _postService.uploadFile(image));
    }

    return await _postService.createPost(
      images: _images,
      title: _title,
      description: _description,
      price: _price,
      expiringDate: _expiringDate,
    );
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
        title: const Text('Create Post'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                editImageWidget(
                  images: tempImages,
                  stringImages: const [],
                ),
                if (!imageSelected)
                  const Text(
                    'Select at least one image to create a post.',
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Select Image Source'),
                            actions: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    child: const Text('Camera'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _pickImageFromCamera();
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  TextButton(
                                    child: const Text('Gallery'),
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
                    child: const Text('Add Image'),
                  ),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _title = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter title";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter description";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    CurrencyTextInputFormatter(
                      decimalDigits: 2,
                      locale: 'eu',
                      symbol: '€',
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _price = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter price";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    labelText: 'Select expiring date',
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      imageSelected = tempImages.isNotEmpty;
                    });
                    if (_formKey.currentState!.validate() &&
                        tempImages.isNotEmpty) {
                      Post? newPost = await _createPost();
                      Navigator.pop(context, newPost);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
