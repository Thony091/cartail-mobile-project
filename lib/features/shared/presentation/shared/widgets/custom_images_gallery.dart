import 'dart:io';

import 'package:flutter/material.dart';

class CustomImagesGallery extends StatelessWidget {

  final List<String> images;
  
  const CustomImagesGallery({super.key, required this.images});

  @override
  Widget build(BuildContext context) {

    return PageView(
      scrollDirection: Axis.horizontal,
      controller: PageController(
        viewportFraction: 0.7
      ),
      children: images.isEmpty
        ? [ 
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: Image.asset('assets/images/no-image.jpg', 
                fit: BoxFit.cover 
              )
            ) 
          ]
        : images.map((image){

          late ImageProvider imageProvider;
          if ( image.startsWith('http') ) {
            imageProvider = NetworkImage(image);
          } else {
            imageProvider = FileImage( File(image) );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: FadeInImage(
                placeholder: const AssetImage('assets/loaders/loader2.gif'),
                image: imageProvider,
                fit: BoxFit.cover,
              )
            ),
          );
      }).toList(),
    );
  }
}

