import 'dart:io';
import 'package:flutter/material.dart';

Widget buildImageWidget(String imagePath, int commodityId, bool isTablet) {
  if (imagePath.isEmpty) {
    return Center(
      child: Icon(Icons.image, size: isTablet ? 28 : 24, color: Colors.grey),
    );
  }

  if (imagePath.startsWith("http")) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        imagePath,
        key: ValueKey("img-$commodityId-$imagePath"),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(Icons.broken_image,
                size: isTablet ? 28 : 24, color: Colors.grey),
          );
        },
      ),
    );
  } else {
    final file = File(imagePath);
    return file.existsSync()
        ? ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(
              file,
              key: ValueKey("img-$commodityId-$imagePath"),
              fit: BoxFit.cover,
            ),
          )
        : Center(
            child:
                Icon(Icons.image, size: isTablet ? 28 : 24, color: Colors.grey),
          );
  }
}
