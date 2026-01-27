import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/better_auth_provider.dart';
import '../../../state/presentation/providers/states_provider.dart';
import '../../../ticket/domain/entities/ticket.dart';
import '../../../ticket/presentation/providers/tickets_provider.dart';
import '../state/operator_checklist_controller.dart';
import '../state/operator_ticket_controller.dart';
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
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsProvider);
    Ticket? ticket;
    for (final item in ticketsState.tickets) {
      if (item.id == widget.orderId) {
        ticket = item;
        break;
      }
    }
    final stateId = ticket?.estado.id ?? 1;
    final checklistState = ref.watch(operatorChecklistControllerProvider(stateId));
    final checklistController =
        ref.read(operatorChecklistControllerProvider(stateId).notifier);
    final stateLabel = ref.watch(stateByIdProvider(stateId))?.name ?? 'Estado';
    final nextStateId =
        ref.read(operatorTicketControllerProvider).nextStateId(stateId);

    if (ticketsState.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFf8fafc),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (ticket == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFf8fafc),
        appBar: AppBar(
          title: const Text('Ticket no encontrado'),
        ),
        body: const Center(child: Text('No se encontró el ticket solicitado.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFf8fafc),
      body: CustomScrollView(
        slivers: [
          // AppBar con info principal
          _buildSliverAppBar(ticket, stateLabel),

          // Contenido
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Barra de progreso y fase actual
                FadeInDown(
                  child: _StatusProgressSection(
                    ticket: ticket,
                    stateLabel: stateLabel,
                    progress: _progressForState(stateId),
                  ),
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
                _DetailsTab(ticket: ticket),
                _TimelineTab(ticket: ticket),
                _ChecklistTab(
                  checklist: checklistState.entries,
                  title: checklistState.title,
                  isCompleted: checklistState.requiredComplete,
                  onToggle: (entry, isChecked) =>
                      checklistController.toggle(entry.item.id, isChecked),
                ),
                _NotesTab(
                  ticket: ticket,
                  checklistNotes: checklistState.checkedEntriesInOrder
                      .map((entry) => entry.item.label)
                      .toList(),
                  checklistTitle: checklistState.title,
                  notesController: _notesController,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(
        ticket: ticket,
        nextStateId: nextStateId,
        checklistNotes: checklistState.checkedEntriesInOrder
            .map((entry) => entry.item.label)
            .toList(),
        checklistTitle: checklistState.title,
        nextStateLabel: ref.watch(stateByIdProvider(nextStateId ?? 0))?.name,
      ),
    );
  }

  Widget _buildSliverAppBar(Ticket ticket, String stateLabel) {
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
                          'Ticket #${ticket.id}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(label: stateLabel),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ticket.nombre.isNotEmpty ? ticket.nombre : 'Trabajo asignado',
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
                        Icons.person,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _clientDisplayName(ticket),
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

  Widget _buildBottomActions({
    required Ticket ticket,
    required int? nextStateId,
    required List<String> checklistNotes,
    required String checklistTitle,
    required String? nextStateLabel,
  }) {
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: nextStateId == null || _isLoading
                ? null
                : () => _handleAdvancePhase(
                      ticket: ticket,
                      nextStateId: nextStateId,
                      checklistNotes: checklistNotes,
                      checklistTitle: checklistTitle,
                      nextStateLabel: nextStateLabel ?? 'Siguiente estado',
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498db),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: const Color(0xFFbdc3c7),
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.arrow_forward),
            label: Text(
              nextStateId == null
                  ? 'Sin cambios disponibles'
                  : 'Actualizar a ${nextStateLabel ?? 'Siguiente'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleAdvancePhase({
    required Ticket ticket,
    required int nextStateId,
    required List<String> checklistNotes,
    required String checklistTitle,
    required String nextStateLabel,
  }) async {
    final notesToSend = _buildAdvanceNotes(checklistNotes, checklistTitle);

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
              'Estas a punto de cambiar el estado a "$nextStateLabel". ¿Deseas continuar?',
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

    final user = ref.read(currentUserProvider);
    final operatorId = user?.id ?? '';
    final operatorName = user?.name ?? user?.email ?? 'Operario';
    final controller = ref.read(operatorTicketControllerProvider);
    final ok = await controller.updateTicketWithNotes(
      ticket: ticket,
      nextStateId: nextStateId,
      notes: notesToSend,
      authorId: operatorId,
      authorName: operatorName,
    );

    setState(() => _isLoading = false);

    if (mounted && ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado a $nextStateLabel'),
          backgroundColor: const Color(0xFF27ae60),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo actualizar el estado'),
          backgroundColor: Color(0xFFe74c3c),
        ),
      );
    }
  }

  String _buildAdvanceNotes(List<String> checklistNotes, String title) {
    final buffer = StringBuffer();
    if (checklistNotes.isNotEmpty) {
      buffer.writeln('$title:');
      for (final note in checklistNotes) {
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

  double _progressForState(int stateId) {
    final states = ref.read(statesProvider);
    if (states.isEmpty) return 0;
    final sorted = [...states]..sort((a, b) => a.id.compareTo(b.id));
    final index = sorted.indexWhere((state) => state.id == stateId);
    if (index == -1) return 0;
    return (index + 1) / sorted.length;
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


}

class _StatusBadge extends StatelessWidget {
  final String label;

  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

String _clientDisplayName(Ticket ticket) {
  if (ticket.idReserva.trim().isNotEmpty) {
    return 'Reserva ${ticket.idReserva}';
  }
  return 'Cliente sin nombre';
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
  final Ticket ticket;

  const _DetailsTab({required this.ticket});

  @override
  Widget build(BuildContext context) {
    const services = <String>[];
    const parts = <String>[];
    final String? estimatedCost = null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cliente
          FadeInUp(
            child: _ClientInfoCard(ticket: ticket),
          ),

          const SizedBox(height: 20),

          // Servicios incluidos
          if (services.isNotEmpty) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: _ServicesCard(services: services),
            ),
            const SizedBox(height: 20),
          ],

          if (parts.isNotEmpty) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _PartsCard(parts: parts),
            ),
            const SizedBox(height: 20),
          ],

          if (estimatedCost != null) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _CostCard(estimatedCost: estimatedCost),
            ),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _ClientInfoCard extends StatelessWidget {
  final Ticket ticket;

  const _ClientInfoCard({required this.ticket});

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
                      _clientDisplayName(ticket),
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
          const Text(
            'Contacto no disponible',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF95a5a6),
            ),
          ),
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
  final List<String> parts;

  const _PartsCard({required this.parts});

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
                  color: const Color(0xFF3498db).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'General',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3498db),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...parts.map((part) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_box_outline_blank,
                    size: 20,
                    color: Color(0xFF95a5a6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    part,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2c3e50),
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
  final String estimatedCost;

  const _CostCard({required this.estimatedCost});

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
                  '\$${_formatPrice(estimatedCost)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
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

  String _formatPrice(String price) {
    return price.replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

// Tab de Timeline
class _TimelineTab extends StatelessWidget {
  final Ticket ticket;

  const _TimelineTab({required this.ticket});

  @override
  Widget build(BuildContext context) {
    const history = <Map<String, dynamic>>[];
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
          if (history.isNotEmpty)
            Column(
              children: history.map((entry) {
                final label = entry['label']?.toString() ??
                    entry['state']?.toString() ??
                    'Estado';
                final notes = entry['notes']?.toString() ?? '';
                final timestamp = entry['createdAt']?.toString();
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFe2e8f0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      if (notes.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          notes,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7f8c8d),
                          ),
                        ),
                      ],
                      if (timestamp != null && timestamp.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          timestamp,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF95a5a6),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            )
          else
            const Text(
              'Sin historial disponible.',
              style: TextStyle(color: Color(0xFF7f8c8d)),
            ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// Tab de Checklist
class _ChecklistTab extends StatelessWidget {
  final List<OperatorChecklistEntry> checklist;
  final String title;
  final bool isCompleted;
  final void Function(OperatorChecklistEntry item, bool isChecked) onToggle;

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
  final OperatorChecklistEntry item;
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
                  item.item.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                if (item.item.isRequired) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Requerido',
                    style: TextStyle(
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
  final Ticket ticket;
  final List<String> checklistNotes;
  final String checklistTitle;
  final TextEditingController notesController;

  const _NotesTab({
    required this.ticket,
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
            note: 'Sin notas adicionales',
            color: const Color(0xFF3498db),
          ),

          const SizedBox(height: 20),

          // Notas del cliente
          _NoteSection(
            title: 'Instrucciones del Cliente',
            icon: Icons.person,
            note: 'Sin instrucciones especiales',
            color: const Color(0xFF27ae60),
          ),

          const SizedBox(height: 20),

          // Descripcion del trabajo
          _NoteSection(
            title: 'Descripcion del Trabajo',
            icon: Icons.description,
            note: ticket.description.isNotEmpty
                ? ticket.description
                : 'Sin descripcion disponible',
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

class _StatusProgressSection extends StatelessWidget {
  final Ticket ticket;
  final String stateLabel;
  final double progress;

  const _StatusProgressSection({
    required this.ticket,
    required this.stateLabel,
    required this.progress,
  });

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado actual: $stateLabel',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFe2e8f0),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF3498db),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (ticket.desde != null) ...[
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
                  'Inicio: ${ticket.desde}',
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
}
