import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/work_order.dart';
import '../widgets/work_phase_widgets.dart';
import '../../../shared/presentation/shared/widgets/widgets.dart';

class WorkOrderDetailPage extends ConsumerStatefulWidget {
  final String orderId;
  static const name = 'WorkOrderDetailPage';

  const WorkOrderDetailPage({super.key, required this.orderId});

  @override
  ConsumerState<WorkOrderDetailPage> createState() =>
      _WorkOrderDetailPageState();
}

class _WorkOrderDetailPageState extends ConsumerState<WorkOrderDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // TODO: Reemplazar con datos del provider
  late WorkOrder _order;
  late List<ChecklistItem> _phaseChecklist;
  final List<String> _checkedChecklistIds = [];
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrder();
    _initChecklist();
  }

  void _loadOrder() {
    // Datos de ejemplo
    _order = _getMockOrder();
  }

  void _initChecklist() {
    _phaseChecklist = _buildChecklistForPhase(_order.currentPhase);
    _checkedChecklistIds
      ..clear()
      ..addAll(
        _phaseChecklist.where((item) => item.isChecked).map((item) => item.id),
      );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8fafc),
      body: CustomScrollView(
        slivers: [
          // AppBar con info principal
          _buildSliverAppBar(),

          // Contenido
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Barra de progreso y fase actual
                FadeInDown(
                  child: _PhaseProgressSection(order: _order),
                ),

                // Tabs de contenido
                _buildTabBar(),
              ],
            ),
          ),

          // Contenido de tabs
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _DetailsTab(order: _order),
                _TimelineTab(order: _order),
                _ChecklistTab(
                  checklist: _phaseChecklist,
                  title: _getChecklistTitle(_order.currentPhase),
                  isCompleted: _isChecklistCompleted,
                  onToggle: _handleChecklistToggle,
                ),
                _NotesTab(
                  order: _order,
                  checklistNotes: _selectedChecklistNotes,
                  checklistTitle: _getChecklistTitle(_order.currentPhase),
                  notesController: _notesController,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFF2c3e50),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone, color: Colors.white),
          onPressed: () {
            // TODO: Llamar al cliente
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () => _showOptionsMenu(),
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
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          '#${_order.orderNumber}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      WorkPriorityBadge(priority: _order.priority),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _order.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_car,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_order.vehicle.fullName} - ${_order.vehicle.licensePlate}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF3498db),
        unselectedLabelColor: const Color(0xFF95a5a6),
        indicatorColor: const Color(0xFF3498db),
        tabs: const [
          Tab(icon: Icon(Icons.info_outline), text: 'Detalles'),
          Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
          Tab(icon: Icon(Icons.checklist), text: 'Checklist'),
          Tab(icon: Icon(Icons.notes), text: 'Notas'),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final canAdvance = _order.currentPhase == WorkPhase.pendingReception
        ? _isChecklistCompleted
        : _order.canAdvance;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: PhaseActionButton(
          currentPhase: _order.currentPhase,
          nextPhase: _order.nextPhase,
          canAdvance: canAdvance,
          isLoading: _isLoading,
          onAdvance: _handleAdvancePhase,
        ),
      ),
    );
  }

  void _handleAdvancePhase() async {
    final nextPhase = _order.nextPhase;
    if (nextPhase == null) return;
    final notesToSend = _buildAdvanceNotes();

    // Confirmar accion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar Accion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estas a punto de cambiar el estado a "${nextPhase.displayName}". ¿Deseas continuar?',
            ),
            if (notesToSend.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Notas que se enviaran',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFf8fafc),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFe2e8f0)),
                ),
                child: Text(
                  notesToSend,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2c3e50),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498db),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    // TODO: Implementar cambio de fase real con notesToSend
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado a ${nextPhase.displayName}'),
          backgroundColor: const Color(0xFF27ae60),
        ),
      );
    }
  }

  List<ChecklistItem> _buildChecklistForPhase(WorkPhase phase) {
    switch (phase) {
      case WorkPhase.pendingReception:
      case WorkPhase.received:
        return _order.receptionChecklist;
      case WorkPhase.diagnosis:
        return const [
          ChecklistItem(
            id: 'diagnosis-1',
            label: 'Revision visual inicial',
            description: 'Revision visual inicial',
            category: 'diagnosis',
          ),
          ChecklistItem(
            id: 'diagnosis-2',
            label: 'Lectura de codigos/errores',
            description: 'Lectura de codigos/errores',
            category: 'diagnosis',
          ),
          ChecklistItem(
            id: 'diagnosis-3',
            label: 'Pruebas funcionales basicas',
            description: 'Pruebas funcionales basicas',
            category: 'diagnosis',
          ),
        ];
      case WorkPhase.inProgress:
        return const [
          ChecklistItem(
            id: 'inprogress-1',
            label: 'Herramientas principales listas',
            description: 'Herramientas principales listas',
            category: 'execution',
          ),
          ChecklistItem(
            id: 'inprogress-2',
            label: 'Materiales generales confirmados',
            description: 'Materiales generales confirmados',
            category: 'execution',
          ),
          ChecklistItem(
            id: 'inprogress-3',
            label: 'Area de trabajo asegurada',
            description: 'Area de trabajo asegurada',
            category: 'execution',
          ),
        ];
      case WorkPhase.qualityCheck:
        return const [
          ChecklistItem(
            id: 'qc-1',
            label: 'Pruebas finales completadas',
            description: 'Pruebas finales completadas',
            category: 'quality',
          ),
          ChecklistItem(
            id: 'qc-2',
            label: 'Limpieza y orden del area',
            description: 'Limpieza y orden del area',
            category: 'quality',
          ),
        ];
      case WorkPhase.completed:
      case WorkPhase.delivered:
      case WorkPhase.waitingParts:
      case WorkPhase.cancelled:
        return const [];
    }
  }

  String _getChecklistTitle(WorkPhase phase) {
    switch (phase) {
      case WorkPhase.pendingReception:
      case WorkPhase.received:
        return 'Checklist de Recepcion';
      case WorkPhase.diagnosis:
        return 'Checklist de Diagnostico';
      case WorkPhase.inProgress:
        return 'Checklist de Trabajo';
      case WorkPhase.qualityCheck:
        return 'Checklist de Calidad';
      case WorkPhase.waitingParts:
        return 'Checklist de Repuestos';
      case WorkPhase.completed:
      case WorkPhase.delivered:
      case WorkPhase.cancelled:
        return 'Checklist';
    }
  }

  void _handleChecklistToggle(ChecklistItem item, bool isChecked) {
    final index = _phaseChecklist.indexWhere((current) => current.id == item.id);
    if (index == -1) return;
    setState(() {
      _phaseChecklist[index] = item.copyWith(isChecked: isChecked);
      if (isChecked) {
        if (!_checkedChecklistIds.contains(item.id)) {
          _checkedChecklistIds.add(item.id);
        }
      } else {
        _checkedChecklistIds.remove(item.id);
      }
    });
  }

  bool get _isChecklistCompleted {
    final requiredItems =
        _phaseChecklist.where((item) => item.isRequired).toList();
    if (requiredItems.isEmpty) {
      return _phaseChecklist.isNotEmpty ? _checkedChecklistIds.isNotEmpty : true;
    }
    return requiredItems.every((item) => item.isChecked);
  }

  List<String> get _selectedChecklistNotes {
    return _checkedChecklistIds.map((id) {
      final item = _phaseChecklist.firstWhere((element) => element.id == id);
      return item.label.isNotEmpty ? item.label : item.description;
    }).toList();
  }

  String _buildAdvanceNotes() {
    final buffer = StringBuffer();
    if (_selectedChecklistNotes.isNotEmpty) {
      buffer.writeln('${_getChecklistTitle(_order.currentPhase)}:');
      for (final note in _selectedChecklistNotes) {
        buffer.writeln('- $note');
      }
    }
    final userNotes = _notesController.text.trim();
    if (userNotes.isNotEmpty) {
      if (buffer.isNotEmpty) {
        buffer.writeln();
      }
      buffer.writeln(userNotes);
    }
    return buffer.toString().trim();
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFe2e8f0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _OptionTile(
              icon: Icons.edit,
              title: 'Agregar Nota',
              onTap: () {
                Navigator.pop(context);
                // TODO: Agregar nota
              },
            ),
            _OptionTile(
              icon: Icons.camera_alt,
              title: 'Tomar Foto',
              onTap: () {
                Navigator.pop(context);
                // TODO: Tomar foto
              },
            ),
            _OptionTile(
              icon: Icons.inventory_2,
              title: 'Solicitar Repuestos',
              onTap: () {
                Navigator.pop(context);
                // TODO: Solicitar repuestos
              },
            ),
            _OptionTile(
              icon: Icons.pause_circle,
              title: 'Pausar Trabajo',
              color: const Color(0xFFe67e22),
              onTap: () {
                Navigator.pop(context);
                // TODO: Pausar
              },
            ),
            _OptionTile(
              icon: Icons.cancel,
              title: 'Reportar Problema',
              color: const Color(0xFFe74c3c),
              onTap: () {
                Navigator.pop(context);
                // TODO: Reportar problema
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  WorkOrder _getMockOrder() {
    return WorkOrder(
      id: widget.orderId,
      ticketId: 'TKT-001',
      orderNumber: '2024-0042',
      clientId: 'client-001',
      clientName: 'Juan Perez',
      clientPhone: '+56 9 1234 5678',
      clientEmail: 'juan.perez@email.com',
      operatorId: 'op-001',
      operatorName: 'Carlos Rodriguez',
      workType: WorkType.cameraInstallation,
      title: 'Instalacion de Camara de Retroceso',
      description:
          'Instalacion de camara de retroceso con pantalla integrada en espejo retrovisor. Incluye cableado y configuracion.',
      services: [
        'Camara HD Vision Nocturna',
        'Espejo con Pantalla 4.3"',
        'Cableado completo',
        'Instalacion profesional',
      ],
      vehicle: const VehicleInfo(
        brand: 'Toyota',
        model: 'Corolla',
        year: 2022,
        licensePlate: 'ABCD-12',
        color: 'Gris Metalico',
        mileage: 35000,
      ),
      currentPhase: WorkPhase.inProgress,
      priority: WorkPriority.normal,
      phaseHistory: [
        PhaseLog(
          phase: WorkPhase.pendingReception,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          operatorName: 'Sistema',
          notes: 'Orden creada',
        ),
        PhaseLog(
          phase: WorkPhase.received,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
          operatorName: 'Carlos Rodriguez',
          notes: 'Vehiculo recibido en buen estado',
        ),
        PhaseLog(
          phase: WorkPhase.diagnosis,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          operatorName: 'Carlos Rodriguez',
          notes: 'Revision de sistema electrico completada',
        ),
        PhaseLog(
          phase: WorkPhase.inProgress,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          operatorName: 'Carlos Rodriguez',
          notes: 'Iniciando instalacion',
        ),
      ],
      receptionChecklist: [
        const ChecklistItem(
          id: '1',
          label: 'Estado exterior del vehiculo',
          description: 'Estado exterior del vehiculo',
          category: 'exterior',
          isRequired: true,
          isChecked: true,
          notes: 'Sin daños visibles',
        ),
        const ChecklistItem(
          id: '2',
          label: 'Nivel de combustible',
          description: 'Nivel de combustible',
          category: 'mechanical',
          isRequired: true,
          isChecked: true,
          notes: '1/4 de tanque',
        ),
        const ChecklistItem(
          id: '3',
          label: 'Kilometraje verificado',
          description: 'Kilometraje verificado',
          category: 'mechanical',
          isRequired: true,
          isChecked: true,
        ),
        const ChecklistItem(
          id: '4',
          label: 'Objetos personales retirados',
          description: 'Objetos personales retirados',
          category: 'interior',
          isChecked: true,
        ),
        const ChecklistItem(
          id: '5',
          label: 'Documentos del vehiculo',
          description: 'Documentos del vehiculo',
          category: 'documents',
          isRequired: true,
          isChecked: true,
        ),
      ],
      receptionCompleted: true,
      receptionDate: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      receptionPhotos: [],
      requiredParts: [
        'Camara de retroceso HD',
        'Espejo retrovisor con pantalla',
        'Kit de cableado',
      ],
      receivedParts: [
        'Camara de retroceso HD',
        'Espejo retrovisor con pantalla',
        'Kit de cableado',
      ],
      allPartsReceived: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      scheduledDate: DateTime.now(),
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      estimatedMinutes: 180,
      estimatedCost: 150000,
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF2c3e50)),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? const Color(0xFF2c3e50),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// Tab de Detalles
class _DetailsTab extends StatelessWidget {
  final WorkOrder order;

  const _DetailsTab({required this.order});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehiculo
          FadeInUp(
            child: VehicleInfoCard(vehicle: order.vehicle),
          ),

          const SizedBox(height: 20),

          // Cliente
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: _ClientInfoCard(order: order),
          ),

          const SizedBox(height: 20),

          // Servicios incluidos
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _ServicesCard(services: order.services),
          ),

          const SizedBox(height: 20),

          // Repuestos
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _PartsCard(order: order),
          ),

          const SizedBox(height: 20),

          // Costo estimado
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _CostCard(order: order),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _ClientInfoCard extends StatelessWidget {
  final WorkOrder order;

  const _ClientInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF27ae60).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF27ae60),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cliente',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF95a5a6),
                      ),
                    ),
                    Text(
                      order.clientName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _ContactRow(
            icon: Icons.phone,
            label: 'Telefono',
            value: order.clientPhone,
            color: const Color(0xFF27ae60),
          ),
          if (order.clientEmail != null) ...[
            const SizedBox(height: 12),
            _ContactRow(
              icon: Icons.email,
              label: 'Email',
              value: order.clientEmail!,
              color: const Color(0xFF3498db),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF95a5a6),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(icon, color: color, size: 20),
          onPressed: () {
            // TODO: Accion de contacto
          },
        ),
      ],
    );
  }
}

class _ServicesCard extends StatelessWidget {
  final List<String> services;

  const _ServicesCard({required this.services});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.build, color: Color(0xFF3498db)),
              SizedBox(width: 8),
              Text(
                'Servicios Incluidos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...services.map(
            (service) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Color(0xFF27ae60),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    service,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartsCard extends StatelessWidget {
  final WorkOrder order;

  const _PartsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2, color: Color(0xFF9b59b6)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Repuestos/Materiales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.allPartsReceived
                      ? const Color(0xFF27ae60).withValues(alpha: 0.1)
                      : const Color(0xFFe67e22).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.allPartsReceived ? 'Completo' : 'Pendiente',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: order.allPartsReceived
                        ? const Color(0xFF27ae60)
                        : const Color(0xFFe67e22),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...order.requiredParts.map((part) {
            final received = order.receivedParts.contains(part);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    received ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 20,
                    color: received
                        ? const Color(0xFF27ae60)
                        : const Color(0xFF95a5a6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    part,
                    style: TextStyle(
                      fontSize: 14,
                      color: received
                          ? const Color(0xFF2c3e50)
                          : const Color(0xFF95a5a6),
                      decoration:
                          received ? null : TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  final WorkOrder order;

  const _CostCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF27ae60).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.monetization_on,
              color: Color(0xFF27ae60),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Costo Estimado',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF95a5a6),
                  ),
                ),
                Text(
                  '\$${_formatPrice(order.estimatedCost)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF27ae60),
                  ),
                ),
              ],
            ),
          ),
          if (order.estimatedMinutes != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Tiempo Est.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF95a5a6),
                  ),
                ),
                Text(
                  _formatDuration(order.estimatedMinutes!),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2c3e50),
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

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
}

// Tab de Timeline
class _TimelineTab extends StatelessWidget {
  final WorkOrder order;

  const _TimelineTab({required this.order});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historial de Progreso',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 20),
          WorkPhaseTimeline(
            currentPhase: order.currentPhase,
            phaseHistory: order.phaseHistory,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// Tab de Checklist
class _ChecklistTab extends StatelessWidget {
  final List<ChecklistItem> checklist;
  final String title;
  final bool isCompleted;
  final void Function(ChecklistItem item, bool isChecked) onToggle;

  const _ChecklistTab({
    required this.checklist,
    required this.title,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist, color: Color(0xFF3498db)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const Spacer(),
              if (isCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27ae60).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Color(0xFF27ae60),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Completado',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF27ae60),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ...checklist.map(
            (item) => _ChecklistItemWidget(
              item: item,
              onChanged: (value) => onToggle(item, value ?? false),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _ChecklistItemWidget extends StatelessWidget {
  final ChecklistItem item;
  final ValueChanged<bool?> onChanged;

  const _ChecklistItemWidget({required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isChecked
              ? const Color(0xFF27ae60).withValues(alpha: 0.3)
              : const Color(0xFFe2e8f0),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: item.isChecked,
            onChanged: onChanged,
            activeColor: const Color(0xFF27ae60),
            checkColor: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label.isNotEmpty ? item.label : item.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.notes!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF7f8c8d),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Tab de Notas
class _NotesTab extends StatelessWidget {
  final WorkOrder order;
  final List<String> checklistNotes;
  final String checklistTitle;
  final TextEditingController notesController;

  const _NotesTab({
    required this.order,
    required this.checklistNotes,
    required this.checklistTitle,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assignment_outlined, color: Color(0xFF3498db)),
                    SizedBox(width: 8),
                    Text(
                      'Notas para actualizar estado',
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
                  checklistTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF95a5a6),
                  ),
                ),
                const SizedBox(height: 8),
                if (checklistNotes.isEmpty)
                  const Text(
                    'Marca elementos del checklist para agregarlos a las notas.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7f8c8d),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: checklistNotes
                        .map(
                          (note) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Color(0xFF27ae60),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    note,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF2c3e50),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Notas adicionales (opcional)',
                    filled: true,
                    fillColor: const Color(0xFFf8fafc),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          // Notas del operador
          _NoteSection(
            title: 'Notas del Operario',
            icon: Icons.engineering,
            note: order.operatorNotes ?? 'Sin notas adicionales',
            color: const Color(0xFF3498db),
          ),

          const SizedBox(height: 20),

          // Notas del cliente
          _NoteSection(
            title: 'Instrucciones del Cliente',
            icon: Icons.person,
            note: order.clientNotes ?? 'Sin instrucciones especiales',
            color: const Color(0xFF27ae60),
          ),

          const SizedBox(height: 20),

          // Descripcion del trabajo
          _NoteSection(
            title: 'Descripcion del Trabajo',
            icon: Icons.description,
            note: order.description,
            color: const Color(0xFF9b59b6),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _NoteSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String note;
  final Color color;

  const _NoteSection({
    required this.title,
    required this.icon,
    required this.note,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7f8c8d),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseProgressSection extends StatelessWidget {
  final WorkOrder order;

  const _PhaseProgressSection({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFe2e8f0)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: WorkProgressBar(
                  progress: order.progressPercentage,
                  currentPhase: order.currentPhase,
                ),
              ),
            ],
          ),
          if (order.startedAt != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.timer,
                  size: 16,
                  color: Color(0xFF95a5a6),
                ),
                const SizedBox(width: 6),
                Text(
                  'Tiempo en trabajo: ${_formatElapsed(order.elapsedTime!)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7f8c8d),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatElapsed(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }
}
