import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/service_status.dart';
import '../widgets/service_tracking_widgets.dart';

/// Página de detalle del servicio para el usuario
class ServiceTrackingDetailPage extends ConsumerStatefulWidget {
  static const name = 'ServiceTrackingDetailPage';
  final String serviceId;

  const ServiceTrackingDetailPage({
    super.key,
    required this.serviceId,
  });

  @override
  ConsumerState<ServiceTrackingDetailPage> createState() =>
      _ServiceTrackingDetailPageState();
}

class _ServiceTrackingDetailPageState
    extends ConsumerState<ServiceTrackingDetailPage> {
  // TODO: Reemplazar con datos del provider
  late UserServiceRequest _service;

  @override
  void initState() {
    super.initState();
    _loadService();
  }

  void _loadService() {
    _service = _getMockService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8fafc),
      body: CustomScrollView(
        slivers: [
          // AppBar
          _buildAppBar(),

          // Mensaje de estado destacado
          SliverToBoxAdapter(
            child: FadeInDown(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StatusMessageCard(status: _service.currentStatus),
              ),
            ),
          ),

          // Barra de progreso
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: _ProgressSection(service: _service),
            ),
          ),

          // Info del vehículo
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: UserVehicleCard(vehicle: _service.vehicle),
              ),
            ),
          ),

          // Detalles del servicio
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _ServiceDetailsCard(service: _service),
            ),
          ),

          // Timeline de actualizaciones
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _UpdatesSection(updates: _service.statusHistory),
            ),
          ),

          // Información de contacto
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: _ContactSection(
                phone: _service.workshopPhone,
                operatorName: _service.assignedOperatorName,
                onCall: _callWorkshop,
              ),
            ),
          ),

          // Espacio final
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      bottomNavigationBar: _service.isReady
          ? _ReadyForPickupBanner(onCall: _callWorkshop)
          : null,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: const Color(0xFF2c3e50),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            // TODO: Refrescar estado
            setState(() {
              _loadService();
            });
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2c3e50), Color(0xFF34495e)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(56, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${_service.orderNumber}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const Spacer(),
                      ServiceStatusBadge(
                        status: _service.currentStatus,
                        showIcon: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _service.serviceName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _callWorkshop() async {
    final uri = Uri.parse('tel:${_service.workshopPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  UserServiceRequest _getMockService() {
    // Simular según el ID
    if (widget.serviceId == 'srv-002') {
      return UserServiceRequest(
        id: 'srv-002',
        orderNumber: '2024-0041',
        serviceName: 'Detailing Premium Completo',
        serviceDescription:
            'Servicio completo de limpieza interior y exterior con aplicación de protección cerámica de alta durabilidad.',
        includedItems: [
          'Lavado exterior premium',
          'Descontaminación de pintura',
          'Pulido de carrocería',
          'Aspirado profundo interior',
          'Limpieza de tapicería',
          'Protección cerámica 6 meses',
          'Acondicionamiento de plásticos',
        ],
        vehicle: const UserVehicleInfo(
          brand: 'Honda',
          model: 'Civic',
          year: 2023,
          licensePlate: 'WXYZ-99',
          color: 'Negro',
        ),
        currentStatus: ServiceStatus.ready,
        statusHistory: [
          StatusUpdate(
            status: ServiceStatus.received,
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            message: 'Vehículo recibido en perfectas condiciones.',
          ),
          StatusUpdate(
            status: ServiceStatus.inProgress,
            timestamp: DateTime.now().subtract(const Duration(hours: 20)),
            message: 'Iniciamos el proceso de detailing.',
          ),
          StatusUpdate(
            status: ServiceStatus.ready,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            message:
                '¡Tu vehículo quedó impecable! La protección cerámica está aplicada y lista. Puedes venir a recogerlo cuando gustes.',
          ),
        ],
        requestedAt: DateTime.now().subtract(const Duration(days: 1)),
        estimatedCost: 180000,
        finalCost: 180000,
        workshopPhone: '+56 2 1234 5678',
        assignedOperatorName: 'Miguel',
      );
    }

    return UserServiceRequest(
      id: widget.serviceId,
      orderNumber: '2024-0042',
      serviceName: 'Instalación de Cámara de Retroceso',
      serviceDescription:
          'Instalación profesional de cámara de retroceso HD con pantalla integrada en espejo retrovisor. Incluye cableado oculto y configuración completa.',
      includedItems: [
        'Cámara HD con visión nocturna',
        'Espejo retrovisor con pantalla 4.3"',
        'Kit de cableado completo',
        'Instalación profesional',
        'Configuración y calibración',
        'Garantía de 12 meses',
      ],
      vehicle: const UserVehicleInfo(
        brand: 'Toyota',
        model: 'Corolla',
        year: 2022,
        licensePlate: 'ABCD-12',
        color: 'Gris Metálico',
      ),
      currentStatus: ServiceStatus.inProgress,
      statusHistory: [
        StatusUpdate(
          status: ServiceStatus.received,
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          message:
              'Tu vehículo ha sido recibido. Todo en orden, comenzaremos pronto.',
        ),
        StatusUpdate(
          status: ServiceStatus.inProgress,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          message:
              'Estamos instalando la cámara y pasando el cableado. ¡Va quedando genial!',
        ),
      ],
      requestedAt: DateTime.now().subtract(const Duration(hours: 5)),
      estimatedCompletionDate: DateTime.now().add(const Duration(hours: 2)),
      estimatedCost: 150000,
      workshopPhone: '+56 2 1234 5678',
      assignedOperatorName: 'Carlos',
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final UserServiceRequest service;

  const _ProgressSection({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.route,
                color: Color(0xFF3498db),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Progreso del Servicio',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ServiceProgressBar(status: service.currentStatus),
          if (service.estimatedTimeRemaining != null &&
              service.isActive) ...[
            const SizedBox(height: 20),
            _EstimatedTimeRow(
              remaining: service.estimatedTimeRemaining!,
            ),
          ],
        ],
      ),
    );
  }
}

class _EstimatedTimeRow extends StatelessWidget {
  final Duration remaining;

  const _EstimatedTimeRow({required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3498db).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.schedule,
            color: Color(0xFF3498db),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tiempo estimado restante',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7f8c8d),
                  ),
                ),
                Text(
                  _formatDuration(remaining),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3498db),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes} minutos';
  }
}

class _ServiceDetailsCard extends StatelessWidget {
  final UserServiceRequest service;

  const _ServiceDetailsCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.build,
                color: Color(0xFF9b59b6),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Detalles del Servicio',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Descripción
          Text(
            service.serviceDescription,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7f8c8d),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Items incluidos
          const Text(
            'Incluye:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 12),
          ...service.includedItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Color(0xFF27ae60),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Costo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Costo Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2c3e50),
                ),
              ),
              Text(
                '\$${_formatPrice(service.finalCost ?? service.estimatedCost)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF27ae60),
                ),
              ),
            ],
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
}

class _UpdatesSection extends StatelessWidget {
  final List<StatusUpdate> updates;

  const _UpdatesSection({required this.updates});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.update,
                color: Color(0xFF3498db),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Actualizaciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ServiceStatusTimeline(updates: updates),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  final String phone;
  final String? operatorName;
  final VoidCallback onCall;

  const _ContactSection({
    required this.phone,
    this.operatorName,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.support_agent,
                color: Color(0xFF27ae60),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '¿Tienes preguntas?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            operatorName != null
                ? '$operatorName está trabajando en tu vehículo. Contáctanos si necesitas algo.'
                : 'Estamos para ayudarte. Contáctanos si tienes alguna duda.',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7f8c8d),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.phone),
              label: Text('Llamar al taller ($phone)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF27ae60),
                side: const BorderSide(color: Color(0xFF27ae60)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyForPickupBanner extends StatelessWidget {
  final VoidCallback onCall;

  const _ReadyForPickupBanner({required this.onCall});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF27ae60),
        boxShadow: [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Listo para recoger!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Tu vehículo te espera',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onCall,
            icon: const Icon(Icons.phone, size: 18),
            label: const Text('Llamar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF27ae60),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
