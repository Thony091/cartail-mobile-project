import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:portafolio_project/features/services/domain/entities/services.dart';
import 'package:portafolio_project/features/services/presentation/page/modern_service_card.dart';
import 'package:portafolio_project/features/services/presentation/page/service_detail_modal.dart';

import '../modern_service_widgets.dart';

class UserServiceListWidget extends StatelessWidget {
  final List<Services> services;

  const UserServiceListWidget({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 100),
            child: ModernServiceCard(
              icon: getServiceIcon(getServiceCategory(service)),
              title: service.name,
              subtitle: service.description,
              price: '\$${service.minPrice} - \$${service.maxPrice}',
              images: service.images,
              onTap: () {
                ServiceDetailModal.show(
                  context,
                  service: service,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
