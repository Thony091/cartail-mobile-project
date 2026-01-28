import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/presentation/shared/widgets/widgets.dart';
import 'modern_service_widgets.dart';
import 'service_image_utils.dart';
import '../../domain/entities/services.dart';

class ServiceDetailModal extends StatelessWidget {
  final Services service;
  final VoidCallback? onAddToCart;
  final VoidCallback? onReserve;

  const ServiceDetailModal({
    super.key,
    required this.service,
    this.onAddToCart,
    this.onReserve,
  });

  static Future<void> show(
    BuildContext context, {
    required Services service,
    VoidCallback? onAddToCart,
    VoidCallback? onReserve,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceDetailModal(
        service: service,
        onAddToCart: onAddToCart,
        onReserve: onReserve,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFe2e8f0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con imagen o icono
                  _buildHeader(),

                  const SizedBox(height: 24),

                  // Nombre del servicio
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2c3e50),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Categoria
                  _buildCategoryChip(),

                  const SizedBox(height: 20),

                  // Precio
                  _buildPriceSection(),

                  const SizedBox(height: 24),

                  // Descripcion
                  _buildDescriptionSection(),

                  const SizedBox(height: 24),

                  // Caracteristicas del servicio
                  // _buildFeaturesSection(),

                  const SizedBox(height: 24),

                  // Informacion adicional
                  _buildInfoSection(),

                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),

          // Bottom action buttons
          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // Usar helper para encontrar primera imagen válida
    final firstImage = firstValidNetworkImage(service.images);
    if (firstImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: FadeInImage(
            placeholder: const AssetImage('assets/loaders/loader2.gif'),
            image: NetworkImage(firstImage),
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 300),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getCategoryGradient(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        getServiceIcon(getServiceCategory(service)),
        color: Colors.white,
        size: 80,
      ),
    );
  }

  List<Color> _getCategoryGradient() {
    switch (getServiceCategory(service).toLowerCase()) {
      case 'detailing':
        return [const Color(0xFF3498db), const Color(0xFF2980b9)];
      case 'mecánica':
        return [const Color(0xFFe67e22), const Color(0xFFd35400)];
      case 'pintura':
        return [const Color(0xFF9b59b6), const Color(0xFF8e44ad)];
      case 'neumáticos':
        return [const Color(0xFF34495e), const Color(0xFF2c3e50)];
      default:
        return [const Color(0xFF27ae60), const Color(0xFF229954)];
    }
  }

  Widget _buildCategoryChip() {
    final category = getServiceCategory(service);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3498db).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3498db),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF27ae60).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.monetization_on,
              color: Color(0xFF27ae60),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Precio del servicio',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7f8c8d),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${_formatPrice(service.minPrice)} - \$${_formatPrice(service.maxPrice)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF27ae60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripcion',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2c3e50),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          service.description.isNotEmpty
              ? service.description
              : 'Este servicio incluye todo lo necesario para mantener tu vehiculo en optimas condiciones. Contamos con personal capacitado y equipos de ultima generacion.',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF7f8c8d),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoRow(Icons.access_time, 'Duracion estimada', '${(service.durationMinutes/60).toStringAsFixed(0).toString()} horas'),
          const Divider(height: 24),
          _buildInfoRow(Icons.verified, 'Garantia', '30 dias'),
          // const Divider(height: 24),
          // _buildInfoRow(Icons.star, 'Calificacion', '4.8/5.0'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF3498db), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7f8c8d),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2c3e50),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: ModernButton(
                text: 'Reservar',
                icon: Icons.calendar_today,
                style: ModernButtonStyle.success,
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onReserve != null) {
                    onReserve!();
                  } else {
                    context.push('/reservations?service=${service.id}');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
