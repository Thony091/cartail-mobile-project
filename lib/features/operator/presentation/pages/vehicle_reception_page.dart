import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/work_order.dart';
import '../widgets/work_phase_widgets.dart';

/// Página de recepción de vehículo con checklist
class VehicleReceptionPage extends ConsumerStatefulWidget {
  static const name = 'VehicleReceptionPage';
  final String orderId;

  const VehicleReceptionPage({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<VehicleReceptionPage> createState() =>
      _VehicleReceptionPageState();
}

class _VehicleReceptionPageState extends ConsumerState<VehicleReceptionPage> {
  late WorkOrder _order;
  late List<ChecklistItem> _checklist;
  final List<String> _photos = [];
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _order = _getMockOrder();
    _checklist = _getDefaultChecklist();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _canComplete {
    final requiredItems = _checklist.where((item) => item.isRequired);
    return requiredItems.every((item) => item.isChecked);
  }

  int get _completedCount => _checklist.where((item) => item.isChecked).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8fafc),
      body: CustomScrollView(
        slivers: [
          // AppBar
          _buildAppBar(),

          // Info del vehículo
          SliverToBoxAdapter(
            child: FadeInDown(
              child: _VehicleInfoSection(order: _order),
            ),
          ),

          // Progreso del checklist
          SliverToBoxAdapter(
            child: FadeInLeft(
              child: _ChecklistProgress(
                completed: _completedCount,
                total: _checklist.length,
              ),
            ),
          ),

          // Secciones del checklist
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    child: _ChecklistSection(
                      title: 'Estado Exterior',
                      icon: Icons.directions_car,
                      items: _checklist
                          .where((i) => i.category == 'exterior')
                          .toList(),
                      onItemChanged: _updateChecklistItem,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _ChecklistSection(
                      title: 'Estado Interior',
                      icon: Icons.airline_seat_recline_normal,
                      items: _checklist
                          .where((i) => i.category == 'interior')
                          .toList(),
                      onItemChanged: _updateChecklistItem,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _ChecklistSection(
                      title: 'Componentes Mecánicos',
                      icon: Icons.settings,
                      items: _checklist
                          .where((i) => i.category == 'mechanical')
                          .toList(),
                      onItemChanged: _updateChecklistItem,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _ChecklistSection(
                      title: 'Documentos y Accesorios',
                      icon: Icons.inventory_2,
                      items: _checklist
                          .where((i) => i.category == 'documents')
                          .toList(),
                      onItemChanged: _updateChecklistItem,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sección de fotos
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _PhotosSection(
                photos: _photos,
                onAddPhoto: _addPhoto,
                onRemovePhoto: _removePhoto,
              ),
            ),
          ),

          // Notas adicionales
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: _NotesSection(controller: _notesController),
            ),
          ),

          // Espacio para el botón
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
      bottomNavigationBar: _BottomActions(
        canComplete: _canComplete,
        isLoading: _isLoading,
        onComplete: _completeReception,
        onSaveDraft: _saveDraft,
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      backgroundColor: const Color(0xFF2c3e50),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
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
              padding: const EdgeInsets.fromLTRB(56, 40, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.fact_check,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Recepción #${_order.orderNumber}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white),
          onPressed: _showHelp,
        ),
      ],
    );
  }

  void _updateChecklistItem(ChecklistItem item, bool value) {
    setState(() {
      final index = _checklist.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _checklist[index] = item.copyWith(isChecked: value);
      }
    });
  }

  void _addPhoto() {
    // TODO: Implementar selección de foto
    setState(() {
      _photos.add('photo_${_photos.length + 1}.jpg');
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _saveDraft() {
    // TODO: Guardar borrador
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Borrador guardado'),
        backgroundColor: Color(0xFF3498db),
      ),
    );
  }

  Future<void> _completeReception() async {
    if (!_canComplete) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF27ae60)),
            SizedBox(width: 12),
            Text('Confirmar Recepción'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Confirmas que has completado la recepción del vehículo?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF27ae60).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF27ae60),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Items completados: $_completedCount/${_checklist.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF27ae60),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27ae60),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);

      // Simular guardado
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recepción completada exitosamente'),
            backgroundColor: Color(0xFF27ae60),
          ),
        );

        context.pop();
      }
    }
  }

  void _showHelp() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ayuda - Recepción de Vehículo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 16),
            _HelpItem(
              icon: Icons.check_box,
              title: 'Items obligatorios',
              description:
                  'Los items marcados con asterisco (*) son obligatorios para completar la recepción.',
            ),
            _HelpItem(
              icon: Icons.camera_alt,
              title: 'Fotos',
              description:
                  'Toma fotos del estado actual del vehículo para documentar cualquier daño existente.',
            ),
            _HelpItem(
              icon: Icons.note_add,
              title: 'Notas',
              description:
                  'Agrega notas sobre observaciones importantes o requerimientos especiales del cliente.',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  WorkOrder _getMockOrder() {
    return WorkOrder(
      id: widget.orderId,
      ticketId: 'TKT-002',
      orderNumber: '2024-0043',
      clientId: 'client-002',
      clientName: 'Maria Garcia',
      clientPhone: '+56 9 8765 4321',
      workType: WorkType.detailing,
      title: 'Detailing Premium Completo',
      description: 'Limpieza interior y exterior con protección cerámica',
      services: ['Lavado exterior', 'Aspirado interior', 'Cerámica'],
      vehicle: const VehicleInfo(
        brand: 'Honda',
        model: 'CR-V',
        year: 2021,
        licensePlate: 'EFGH-34',
        color: 'Blanco',
        mileage: 42000,
      ),
      currentPhase: WorkPhase.pendingReception,
      priority: WorkPriority.high,
      phaseHistory: [],
      receptionChecklist: [],
      receptionCompleted: false,
      receptionPhotos: [],
      requiredParts: [],
      receivedParts: [],
      allPartsReceived: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      estimatedMinutes: 240,
      estimatedCost: 180000,
    );
  }

  List<ChecklistItem> _getDefaultChecklist() {
    return [
      // Exterior
      const ChecklistItem(
        id: 'ext_1',
        label: 'Carrocería sin daños visibles',
        category: 'exterior',
        isRequired: true,
      ),
      const ChecklistItem(
        id: 'ext_2',
        label: 'Vidrios en buen estado',
        category: 'exterior',
        isRequired: true,
      ),
      const ChecklistItem(
        id: 'ext_3',
        label: 'Espejos laterales funcionando',
        category: 'exterior',
        isRequired: false,
      ),
      const ChecklistItem(
        id: 'ext_4',
        label: 'Luces funcionando correctamente',
        category: 'exterior',
        isRequired: false,
      ),
      const ChecklistItem(
        id: 'ext_5',
        label: 'Neumáticos en buen estado',
        category: 'exterior',
        isRequired: true,
      ),
      // Interior
      const ChecklistItem(
        id: 'int_1',
        label: 'Tablero sin daños',
        category: 'interior',
        isRequired: true,
      ),
      const ChecklistItem(
        id: 'int_2',
        label: 'Asientos en buen estado',
        category: 'interior',
        isRequired: false,
      ),
      const ChecklistItem(
        id: 'int_3',
        label: 'Aire acondicionado funcional',
        category: 'interior',
        isRequired: false,
      ),
      const ChecklistItem(
        id: 'int_4',
        label: 'Radio/Sistema multimedia',
        category: 'interior',
        isRequired: false,
      ),
      // Mecánico
      const ChecklistItem(
        id: 'mech_1',
        label: 'Nivel de combustible registrado',
        category: 'mechanical',
        isRequired: true,
      ),
      const ChecklistItem(
        id: 'mech_2',
        label: 'Kilometraje registrado',
        category: 'mechanical',
        isRequired: true,
      ),
      const ChecklistItem(
        id: 'mech_3',
        label: 'Sin luces de advertencia',
        category: 'mechanical',
        isRequired: false,
      ),
      // Documentos
      const ChecklistItem(
        id: 'doc_1',
        label: 'Llaves recibidas',
        category: 'documents',
        isRequired: true,
      ),
      const ChecklistItem(
        id: 'doc_2',
        label: 'Documentos del vehículo',
        category: 'documents',
        isRequired: false,
      ),
      const ChecklistItem(
        id: 'doc_3',
        label: 'Rueda de repuesto',
        category: 'documents',
        isRequired: false,
      ),
      const ChecklistItem(
        id: 'doc_4',
        label: 'Kit de herramientas',
        category: 'documents',
        isRequired: false,
      ),
    ];
  }
}

class _VehicleInfoSection extends StatelessWidget {
  final WorkOrder order;

  const _VehicleInfoSection({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF3498db).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: Color(0xFF3498db),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.vehicle.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2c3e50),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            order.vehicle.licensePlate,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.vehicle.color,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7f8c8d),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              WorkPriorityBadge(priority: order.priority),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.person_outline,
                  label: 'Cliente',
                  value: order.clientName,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.build_outlined,
                  label: 'Trabajo',
                  value: order.workType.displayName,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF95a5a6)),
        const SizedBox(width: 8),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2c3e50),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChecklistProgress extends StatelessWidget {
  final int completed;
  final int total;

  const _ChecklistProgress({
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso del Checklist',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2c3e50),
                ),
              ),
              Text(
                '$completed / $total items',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3498db),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFe2e8f0),
              valueColor: AlwaysStoppedAnimation(
                progress == 1.0
                    ? const Color(0xFF27ae60)
                    : const Color(0xFF3498db),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ChecklistItem> items;
  final Function(ChecklistItem, bool) onItemChanged;

  const _ChecklistSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.onItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
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
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withValues(alpha: 0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF3498db), size: 22),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const Spacer(),
                Text(
                  '${items.where((i) => i.isChecked).length}/${items.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF95a5a6),
                  ),
                ),
              ],
            ),
          ),
          // Items
          ...items.map(
            (item) => _ChecklistItemTile(
              item: item,
              onChanged: (value) => onItemChanged(item, value),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItemTile extends StatelessWidget {
  final ChecklistItem item;
  final ValueChanged<bool> onChanged;

  const _ChecklistItemTile({
    required this.item,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFf1f5f9)),
        ),
      ),
      child: CheckboxListTile(
        value: item.isChecked,
        onChanged: (value) => onChanged(value ?? false),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  color: item.isChecked
                      ? const Color(0xFF95a5a6)
                      : const Color(0xFF2c3e50),
                  decoration:
                      item.isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (item.isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFe74c3c).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Requerido',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFe74c3c),
                  ),
                ),
              ),
          ],
        ),
        activeColor: const Color(0xFF27ae60),
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

class _PhotosSection extends StatelessWidget {
  final List<String> photos;
  final VoidCallback onAddPhoto;
  final Function(int) onRemovePhoto;

  const _PhotosSection({
    required this.photos,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.camera_alt, color: Color(0xFF3498db), size: 22),
                  SizedBox(width: 12),
                  Text(
                    'Fotos de Recepción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onAddPhoto,
                icon: const Icon(Icons.add_a_photo, size: 18),
                label: const Text('Agregar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (photos.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFf8fafc),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFe2e8f0),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: Color(0xFFbdc3c7),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Toca para agregar fotos del vehículo',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF95a5a6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  if (index == photos.length) {
                    return GestureDetector(
                      onTap: onAddPhoto,
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFf8fafc),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF3498db),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            color: Color(0xFF3498db),
                            size: 32,
                          ),
                        ),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFe2e8f0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            color: const Color(0xFF95a5a6).withValues(alpha: 0.5),
                            size: 40,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => onRemovePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFe74c3c),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  final TextEditingController controller;

  const _NotesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.note_add, color: Color(0xFF3498db), size: 22),
              SizedBox(width: 12),
              Text(
                'Notas Adicionales',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Observaciones sobre el estado del vehículo, daños existentes, instrucciones especiales...',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF95a5a6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3498db)),
              ),
              filled: true,
              fillColor: const Color(0xFFf8fafc),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final bool canComplete;
  final bool isLoading;
  final VoidCallback onComplete;
  final VoidCallback onSaveDraft;

  const _BottomActions({
    required this.canComplete,
    required this.isLoading,
    required this.onComplete,
    required this.onSaveDraft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onSaveDraft,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Guardar'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: canComplete && !isLoading ? onComplete : null,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(isLoading ? 'Procesando...' : 'Completar Recepción'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27ae60),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor:
                    const Color(0xFF27ae60).withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF3498db), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7f8c8d),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
