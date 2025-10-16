import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:marquee/marquee.dart';

import '../../../../config/config.dart';
import '../../../../domain/domain.dart';


class ServiceCard extends StatelessWidget {

  final Services service;

  const ServiceCard({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ImageViewer(
          images: service.images,
          title: service.name,
          description: service.description,
          minPrice: service.minPrice,
          maxPrice: service.maxPrice,
        ),
        const SizedBox(height: 20)
      ],
    );
  }
}

class _ImageViewer extends StatelessWidget {

  final List<String> images;
  final String title;
  final String description;
  final int minPrice;
  final int maxPrice;

  const _ImageViewer({
    required this.images,
    this.title = '',
    this.description = '',
    this.minPrice = 0,
    this.maxPrice = 0,
  });

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    if ( images.isEmpty ) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
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
                height: 200,
                width: size.width * 0.5,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Marquee(
                    //   text: title,
                    //   style: const TextStyle(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   blankSpace: 20,
                    //   velocity: 50,

                    // ),
                    SizedBox(
                      height: 20,
                      child: Marquee(
                        text: title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        blankSpace: title.length.toDouble() * 3,
                        velocity: 30.0,
                        pauseAfterRound: const Duration(seconds: 4),
                        startPadding: 1,
                        accelerationDuration: const Duration(seconds: 2),
                        accelerationCurve: Curves.linear,
                        decelerationDuration: const Duration(milliseconds: 500),
                        decelerationCurve: Curves.easeOut,
                      ),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      height: 40,
                      child: Marquee(
                        text: description,
                        style: const TextStyle(
                            fontSize: 14,
                        ),
                        scrollAxis: Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        startPadding: 1,
                        blankSpace: 50,
                        velocity: 5.0,

                      ),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      height: 15,
                      child: Marquee(
                        text: 'Desde: \$${Formats.formatPriceNumber(minPrice).toString()} - ${Formats.formatPriceNumber(maxPrice).toString()} ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        ),
                        pauseAfterRound: const Duration(seconds: 3),
                        velocity: 20,
                        blankSpace: 50,
                        startPadding: 35,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
      borderRadius: BorderRadius.circular(5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
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
              height: 200,
              width: size.width * 0.5,
              fadeOutDuration: const Duration(milliseconds: 100),
              fadeInDuration: const Duration(milliseconds: 200),
              image: NetworkImage( images.first ),
              placeholder: const AssetImage('assets/loaders/loader2.gif'),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(
                    height: 20,
                    child: Marquee(
                      text: title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      blankSpace: title.length.toDouble() * 3,
                      velocity: 30.0,
                      pauseAfterRound: const Duration(seconds: 4),
                      startPadding: 1,
                      accelerationDuration: const Duration(seconds: 2),
                      accelerationCurve: Curves.linear,
                      decelerationDuration: const Duration(milliseconds: 500),
                      decelerationCurve: Curves.easeOut,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: Marquee(
                      text: description,
                      style: const TextStyle(
                          fontSize: 14,
                      ),
                      scrollAxis: Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      startPadding: 1,
                      blankSpace: 50,
                      velocity: 5.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 15,
                    child: Marquee(
                      text: 'Desde: \$${Formats.formatPriceNumber(minPrice).toString()} - ${Formats.formatPriceNumber(maxPrice).toString()} ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                      ),
                      pauseAfterRound: const Duration(seconds: 3),
                      velocity: 20,
                      blankSpace: 50,
                      startPadding: 35,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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