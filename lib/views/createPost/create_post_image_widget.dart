import 'dart:io';

import 'package:flutter/material.dart';

class editImageWidget extends StatefulWidget {
  final List<File> images;
  final List<String> stringImages;

  const editImageWidget({Key? key, required this.images, required this.stringImages}) : super(key: key);

  @override
  _editImageWidgetState createState() => _editImageWidgetState();
}

class _editImageWidgetState extends State<editImageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 355,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: _buildCarousel(context),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    List<String> allImages = [...widget.stringImages];
    allImages.addAll(widget.images.map((file) => file.path));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 320,
          width: MediaQuery.of(context).size.width,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: allImages.length,
            itemBuilder: (BuildContext context, int itemIndex) {
              return _buildCarouselItem(context, allImages[itemIndex]);
            },
          ),
        )
      ],
    );
  }

  Widget _buildCarouselItem(BuildContext context, String imagePath) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            'http://nocng.id.vn:9000/commons/$imagePath',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
