import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../auth/presentation/providers/better_auth_provider.dart';
import '../providers/factura_provider.dart';
import 'modern_factura_detail_widgets.dart';

class ModernFacturaDetailPage extends ConsumerStatefulWidget {
  static const name = 'ModernFacturaDetailPage';
  final String facturaId;

  const ModernFacturaDetailPage({super.key, required this.facturaId});

  @override
  ModernFacturaDetailPageState createState() => ModernFacturaDetailPageState();
}

class ModernFacturaDetailPageState
    extends ConsumerState<ModernFacturaDetailPage> {
  @override
  Widget build(BuildContext context) {
    final facturaState = ref.watch(facturaByIdProvider(widget.facturaId));
    final authState = ref.watch(betterAuthProvider);
    final factura = facturaState.factura;

    if (facturaState.isLoading) {
      return const ModernScaffoldWithDrawer(
        title: 'Cargando...',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (factura == null) {
      return const ModernScaffoldWithDrawer(
        title: 'Error',
        body: Center(child: Text('No se pudo cargar la factura')),
      );
    }

    final isNewFactura = widget.facturaId == 'new';
    final canEdit = authState.isAdmin || authState.isOperator;
    final isEditMode = canEdit ? facturaState.isEditMode : false;
    final facturaNotifier = ref
        .read(facturaByIdProvider(widget.facturaId).notifier);

    return ModernScaffoldWithDrawer(
      title: isNewFactura
          ? 'Crear Factura'
          : isEditMode
              ? 'Editar Factura'
              : 'Detalle de Factura',
      appBarActions: [
        if (canEdit && !isNewFactura && !isEditMode)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => facturaNotifier.setEditMode(true),
          ),
        if (canEdit && isEditMode && !isNewFactura)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => facturaNotifier.setEditMode(false),
          ),
      ],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFF667eea).withValues(alpha: 0.04),
              const Color(0xFF764ba2).withValues(alpha: 0.04),
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FacturaFormFields(
                factura: factura,
                isEditMode: isEditMode,
              ),
              const SizedBox(height: 24),
              if (canEdit && isEditMode)
                FacturaActionButtons(factura: factura),
            ],
          ),
        ),
      ),
    );
  }
}
