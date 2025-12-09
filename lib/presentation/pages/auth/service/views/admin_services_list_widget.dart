import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:portafolio_project/presentation/pages/auth/service/modern_service_page.dart';
import 'package:portafolio_project/presentation/pages/auth/service/views/components/admin_service_card_widget.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_button.dart';

class AdminServiceListWidget extends StatelessWidget {
  final List<ServiceData> services;
  // final Future<bool> Function(ServiceData) onDelete;

  const AdminServiceListWidget({
    super.key,
    required this.services,
    // required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final service = services[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 100),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: AdminServiceCardWidget(
                service: service,
                onDelete: (_) async => await _showDeleteConfirmation(service, context),
                // onDelete: onDelete,
              ),
            ),
          );
        },
        childCount: services.length,
      ),
    );
  }
    Future<bool> _showDeleteConfirmation(ServiceData service, BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Servicio'),
        content: Text('¿Estás seguro de que deseas eliminar "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ModernButton(
            text: 'Eliminar',
            style: ModernButtonStyle.danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ?? false;
  }
}
