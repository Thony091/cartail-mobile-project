import 'dart:io';

import 'package:flutter/material.dart';

class CustomImageGallery extends StatelessWidget {

  final String image;
  
  const CustomImageGallery({super.key, required this.image});

  @override
  Widget build(BuildContext context) {

    late ImageProvider imageProvider;

    Widget imageComprobation(String image){

      if ( image.startsWith('http') || image.startsWith('https') ) {
        imageProvider = NetworkImage(image);
      } else {
        imageProvider = FileImage(File(image));
      }

      return Padding(
        padding: const EdgeInsets.symmetric( horizontal: 10),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: FadeInImage(
            image: imageProvider,
            fit: BoxFit.cover,
            placeholder: const AssetImage('assets/loaders/loader2.gif'),
          ),
        ),
      );

    }

    return SizedBox(
      child: image.isEmpty
        ? ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Image.asset('assets/images/no-image.jpg', fit: BoxFit.cover )
          ) 
        : 
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: imageComprobation(image),
          )
    );
  }
}

