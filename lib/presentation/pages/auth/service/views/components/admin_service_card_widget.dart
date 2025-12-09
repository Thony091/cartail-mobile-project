import 'package:flutter/material.dart';
import 'package:portafolio_project/presentation/pages/auth/service/modern_service_page.dart';
import 'package:portafolio_project/presentation/pages/auth/service/views/components/dismiss_background_widget.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_card.dart';

class AdminServiceCardWidget extends StatelessWidget {
  final ServiceData service;
  final Future<bool> Function(ServiceData) onDelete;

  const AdminServiceCardWidget({
    super.key,
    required this.service,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(service.id),
      direction: DismissDirection.horizontal,
      background: const DismissBackground(
        color: Colors.blue,
        icon: Icons.edit,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: const DismissBackground(
        color: Colors.red,
        icon: Icons.delete,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Editar servicio
          return false;
        } else {
          // Eliminar servicio
          return await onDelete(service);
        }
      },
      child: ModernCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Imagen del servicio
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: const Color(0xFF3498db).withValues(alpha: .1),
                child: service.images.isNotEmpty
                    ? Image.network(
                        service.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            getServiceIcon(service.category),
                            color: const Color(0xFF3498db),
                            size: 32,
                          );
                        },
                      )
                    : Icon(
                        getServiceIcon(service.category),
                        color: const Color(0xFF3498db),
                        size: 32,
                      ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7f8c8d),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27ae60).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '\$${service.minPrice} - \$${service.maxPrice}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF27ae60),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Acciones
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF3498db)),
                  onPressed: () {
                    // Editar servicio
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
                  onPressed: () async {
                    if (await onDelete(service)) {
                      // Eliminar servicio
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}