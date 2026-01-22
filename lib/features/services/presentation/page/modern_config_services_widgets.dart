import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_card.dart';
import '../../domain/entities/services.dart';
import 'modern_service_widgets.dart';

class ServicesHeader extends StatelessWidget {
  final int totalServices;

  const ServicesHeader({super.key, required this.totalServices});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Panel de Administración',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestiona tus servicios desde aquí',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          // Estadísticas
          Row(
            children: [
              Expanded(
                child: ServiceStatCard(
                  label: 'Total Servicios',
                  value: totalServices.toString(),
                  icon: Icons.build_circle,
                  color: const Color(0xFF3498db),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ServiceStatCard(
                  label: 'Activos',
                  value: totalServices.toString(),
                  icon: Icons.check_circle,
                  color: const Color(0xFF27ae60),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ServiceStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const ServiceStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class EmptyServicesView extends StatelessWidget {
  final VoidCallback onCreate;

  const EmptyServicesView({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF3498db).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.build_outlined,
                size: 60,
                color: Color(0xFF3498db),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'No hay servicios registrados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Comienza creando tu primer servicio',
              style: TextStyle(fontSize: 16, color: Color(0xFF7f8c8d)),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ModernButton(
                text: 'Crear Servicio',
                icon: Icons.add,
                onPressed: onCreate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminServicesList extends StatelessWidget {
  final List<Services> services;
  final Function(Services) onEdit;
  final Future<bool> Function(Services) onDelete;
  final Function(Services) onTap;
  final Function(Services) onShowOptions;

  const AdminServicesList({
    super.key,
    required this.services,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    required this.onShowOptions,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final service = services[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 50),
            child: ServiceAdminCard(
              service: service,
              onEdit: () => onEdit(service),
              onDelete: () => onDelete(service),
              onTap: () => onTap(service),
              onShowOptions: () => onShowOptions(service),
            ),
          );
        }, childCount: services.length),
      ),
    );
  }
}

class ServiceAdminCard extends StatelessWidget {
  final Services service;
  final VoidCallback onEdit;
  final Future<bool> Function() onDelete;
  final VoidCallback onTap;
  final VoidCallback onShowOptions;

  const ServiceAdminCard({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    required this.onShowOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(service.id),
      background: const DismissBackground(
        color: Color(0xFF3498db),
        icon: Icons.edit,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: const DismissBackground(
        color: Color(0xFFe74c3c),
        icon: Icons.delete,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Editar
          onEdit();
          return false;
        } else {
          // Eliminar
          return await onDelete();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: ModernCard(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  // Imagen del servicio
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF3498db).withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.car_repair,
                      color: Color(0xFF3498db),
                      size: 40,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Información del servicio
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2c3e50),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          getServiceCategory(service),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF27ae60).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 12,
                                    color: Color(0xFF27ae60),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Activo',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF27ae60),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '\$${service.minPrice} - \$${service.maxPrice}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3498db),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Botón de más opciones
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: onShowOptions,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DismissBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Alignment alignment;

  const DismissBackground({
    super.key,
    required this.color,
    required this.icon,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
