import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../shared/presentation/shared/widgets/modern_floating_action_button.dart';
import '../providers/factura_provider.dart';
import '../../domain/entities/factura.dart';
import 'modern_factura_widgets.dart';

class ModernConfigFacturasPage extends ConsumerStatefulWidget {
  static const name = 'ModernConfigFacturasPage';

  const ModernConfigFacturasPage({super.key});

  @override
  ModernConfigFacturasPageState createState() => ModernConfigFacturasPageState();
}

class ModernConfigFacturasPageState
    extends ConsumerState<ModernConfigFacturasPage> {
  String _searchQuery = '';
  String _sortBy = 'Recientes';

  final List<String> _sortOptions = [
    'Recientes',
    'Antiguos',
    'Total +',
    'Total -',
  ];

  @override
  Widget build(BuildContext context) {
    final facturaState = ref.watch(facturaProvider);
    final facturas = _filterAndSortFacturas(facturaState.facturas);

    return ModernScaffoldWithDrawer(
      title: 'Gestión de Facturas',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => ref.read(facturaProvider.notifier).getFacturas(),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort, color: Colors.white),
          onSelected: (value) => setState(() => _sortBy = value),
          itemBuilder: (context) => _sortOptions
              .map((option) => PopupMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
        ),
      ],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withOpacity(0.08),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por identificador, estado o transacción',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            Expanded(
              child: facturaState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : facturas.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 80),
                        EmptyFacturasView(
                          title: 'No hay facturas registradas',
                          subtitle:
                              'Crea una factura para verla en esta lista.',
                          onAction: () => context.push('/factura-edit/new'),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: facturas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final factura = facturas[index];
                        return _FacturaAdminCard(
                          factura: factura,
                          onTap: () =>
                              context.push('/factura-edit/${factura.id}'),
                          onDelete: () async {
                            final confirmed =
                                await _confirmDeleteFactura(context);
                            if (!confirmed) return;
                            await ref
                                .read(facturaProvider.notifier)
                                .deleteFactura(factura.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Factura eliminada'),
                                  backgroundColor: Color(0xFFe74c3c),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: ModernFloatingActionButton(
        tooltip: 'Crear Factura',
        icon: Icons.add,
        onPressed: () => context.push('/factura-edit/new'),
      ),
    );
  }

  List<Factura> _filterAndSortFacturas(List<Factura> facturas) {
    var filtered = facturas.where((factura) {
      final query = _searchQuery.toLowerCase();
      if (query.isEmpty) return true;
      final haystack = [
        factura.identificadorFactura,
        factura.estado,
        factura.id,
        factura.idTransaccion.toString(),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();

    switch (_sortBy) {
      case 'Recientes':
        filtered.sort((a, b) => b.fechaEmision.compareTo(a.fechaEmision));
        break;
      case 'Antiguos':
        filtered.sort((a, b) => a.fechaEmision.compareTo(b.fechaEmision));
        break;
      case 'Total +':
        filtered.sort((a, b) => b.total.compareTo(a.total));
        break;
      case 'Total -':
        filtered.sort((a, b) => a.total.compareTo(b.total));
        break;
    }

    return filtered;
  }

  Future<bool> _confirmDeleteFactura(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar factura'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta factura?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFe74c3c),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ??
    false;
  }
}

class _FacturaAdminCard extends StatelessWidget {
  final Factura factura;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FacturaAdminCard({
    required this.factura,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('factura-${factura.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFe74c3c),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete;
        return false;
      },
      child: FacturaSummaryCard(
        factura: factura,
        onTap: onTap,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.edit, 
                color: Color(0xFF667eea),
              ),
              onPressed: onTap,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete, 
                color: Color(0xFFe74c3c),
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
