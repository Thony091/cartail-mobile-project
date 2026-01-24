import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../providers/factura_provider.dart';
import 'modern_factura_widgets.dart';

class ModernFacturaPage extends ConsumerWidget {
  static const name = 'ModernFacturaPage';

  const ModernFacturaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facturaState = ref.watch(userFacturasProvider);

    return ModernScaffoldWithDrawer(
      title: 'Mis Facturas',
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
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(userFacturasProvider.notifier).getFacturasByUser();
          },
          child: facturaState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : facturaState.facturas.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        EmptyFacturasView(
                          title: 'No tienes facturas aún',
                          subtitle: 'Cuando completes un servicio verás tus facturas aquí.',
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: facturaState.facturas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final factura = facturaState.facturas[index];
                        return FacturaSummaryCard(
                          factura: factura,
                          onTap: () {
                            ref
                                .read(userFacturasProvider.notifier)
                                .refreshFacturaById(factura.id);
                            context.push('/factura-edit/${factura.id}');
                          },
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
