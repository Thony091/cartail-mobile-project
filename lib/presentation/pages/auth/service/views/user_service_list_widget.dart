import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_service_card.dart';
import 'package:portafolio_project/presentation/pages/auth/service/modern_service_page.dart';

class UserServiceListWidget extends StatelessWidget {
  final List<ServiceData> services;

  const UserServiceListWidget({
    super.key,
    required this.services,
  });

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
              icon: getServiceIcon(service.category),
              title: service.name,
              subtitle: service.description,
              price: '\$${service.minPrice} - \$${service.maxPrice}',
              images: service.images,
              onTap: () {
                // Navegar a detalles del servicio
              },
            ),
          );
        },
      ),
    );
  }
}