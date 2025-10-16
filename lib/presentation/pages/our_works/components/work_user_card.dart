import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../../../../domain/domain.dart';

class WorkUserCard extends StatelessWidget {

  final Works work;

  const WorkUserCard({
    super.key, 
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        _ImageViewer( 
          image: work.image,
          title: work.name,
          description: work.description,
        ),
        // Text( work.name, textAlign: TextAlign.center, ),
        const SizedBox(height: 5)
      ],
    );
  }
}

class _ImageViewer extends StatelessWidget {

  final String image;
  final String title;
  final String description;

  const _ImageViewer({
    required this.image,
    this.title = '', 
    this.description = '',
  });

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    
    if ( image.isEmpty ) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.white,
                blurRadius: 5,
                offset: Offset(0, 3)
              ),
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/no-image.jpg', 
                fit: BoxFit.cover,
                height: 250,
                width: size.width * 0.93,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox( height: 5,),
                    SizedBox(
                      height: 70,
                      child: Marquee(
                        scrollAxis: Axis.vertical,
                        velocity: 5,
                        blankSpace: 20
                        ,
                        text: description,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10)
            ],
          ),
        ),
      );
    }

    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.white,
                blurRadius: 5,
                offset: Offset(0, 3)
              ),
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInImage(
                fit: BoxFit.cover,
                height: 250,
                width: size.width * 0.95,
                fadeOutDuration: const Duration(milliseconds: 100),
                fadeInDuration: const Duration(milliseconds: 200),
                image: NetworkImage( image ),
                placeholder: const AssetImage('assets/loaders/loader2.gif'),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox( height: 5,),
                    SizedBox(
                      height: 70,
                      child: Marquee(
                        scrollAxis: Axis.vertical,
                        velocity: 5,
                        blankSpace: 20
                        ,
                        text: description,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10)
            ],
          ),
        ),
      );

  }
}