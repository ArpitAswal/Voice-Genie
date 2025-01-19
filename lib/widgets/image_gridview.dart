import 'dart:io';

import 'package:flutter/material.dart';

class ImageGridView extends StatelessWidget {
  const ImageGridView({super.key, required this.images});
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Image.file(
          fit: BoxFit.cover,
          height: height * 0.125,
          File(images[0]),
        ),
      );
    } else {
      return GridView.count(
        shrinkWrap: true,
        mainAxisSpacing: 6.0,
        crossAxisSpacing: 6.0,
        crossAxisCount: (images.length <= 4) ? 2 : 3,
        childAspectRatio: 0.85,
        children: images
            .map(
              (image) => ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.file(
                  fit: BoxFit.cover,
                  File(image),
                ),
              ),
            )
            .toList(),
      );
    }
  }
}
