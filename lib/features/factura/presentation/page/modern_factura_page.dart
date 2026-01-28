import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../auth/presentation/providers/better_auth_provider.dart';
import '../../../reservation/presentation/providers/reservation_provider.dart';
import '../../../reservation/domain/entities/reservation.dart';
import '../../domain/entities/factura.dart';
import '../providers/factura_provider.dart';
import 'modern_factura_widgets.dart';

class ModernFacturaPage extends ConsumerWidget {
  static const name = 'ModernFacturaPage';

  const ModernFacturaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facturaState = ref.watch(userFacturasProvider);
    final authState = ref.watch(betterAuthProvider);
    final reservationState = ref.watch(reservationProvider);

    // Obtener las facturas filtradas por usuario
    final userFacturas = _filterUserFacturas(
      facturaState.facturas,
      reservationState.reservations,
      authState.user?.id,
    );

    return ModernScaffoldWithDrawer(
      title: 'Mis Facturas',
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withValues(alpha: 0.08),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(userFacturasProvider.notifier).getFacturasByUser();
          },
          child: facturaState.isLoading || authState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : userFacturas.isEmpty
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
                      itemCount: userFacturas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final factura = userFacturas[index];
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

  /// Filtra las facturas del usuario actual usando match entre
  /// idTransaccion de facturas y reservas, y clientId de reservas
  List<Factura> _filterUserFacturas(
    List<Factura> facturas,
    List<Reservation> reservations,
    String? userId,
  ) {
    if (userId == null) {
      return [];
    }

    // Obtener IDs de transacción de las reservas del usuario
    final userTransactionIds = reservations
        .where((res) => res.clientId?.toString() == userId)
        .map((res) => int.tryParse(res.idTransaccion ?? '') ?? -1)
        .where((id) => id != -1)
        .toSet();

    // Filtrar facturas que coincidan con las transacciones del usuario
    return facturas
        .where((factura) => userTransactionIds.contains(factura.idTransaccion))
        .toList();
  }
}
