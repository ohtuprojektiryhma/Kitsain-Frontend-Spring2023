import 'dart:io';

import 'package:flutter/material.dart';

class feedImageWidget extends StatefulWidget {
  final List<String> images;

  const feedImageWidget({super.key, required this.images});

  @override
  _feedImageWidgetState createState() => _feedImageWidgetState();
}

class _feedImageWidgetState extends State<feedImageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 355,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: widget.images.isNotEmpty
          ? _buildCarousel(context)
          : Container(
              height: 250,
              color: Colors.grey,
            ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 320,
          width: MediaQuery.of(context).size.width,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: widget.images.length,
            itemBuilder: (BuildContext context, int itemIndex) {
              return _buildCarouselItem(context, itemIndex);
            },
          ),
        )
      ],
    );
  }

  Widget _buildCarouselItem(BuildContext context, int itemIndex) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            'http://nocng.id.vn:9000/commons/${widget.images[itemIndex]}',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
