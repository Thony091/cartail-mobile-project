import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme/modern_app_theme.dart';
import '../../core/connectivity/connectivity_providers.dart';
import '../../core/connectivity/connectivity_status.dart';

/// Lineamientos UI (conectividad):
/// - Solo visible en CONEXION_BAJA u OFFLINE.
/// - Gradiente naranja (baja) / rojo (offline).
/// - Forma tipo píldora con laterales totalmente circulares.
/// - Flota arriba, sobre toda la app, con animación suave.
/// - Muestra latencia y indicador visual de calidad de conexión.
class ConnectivityBannerLayer extends ConsumerWidget {
  const ConnectivityBannerLayer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(connectivitySnapshotProvider);

    return Stack(
      children: [
        child,
        Positioned(
          left: ModernAppTheme.paddingMedium,
          right: ModernAppTheme.paddingMedium,
          top: MediaQuery.of(context).padding.top + ModernAppTheme.paddingMedium,
          child: snapshotAsync.when(
            data: (snapshot) => ConnectivityBanner(snapshot: snapshot),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({
    super.key,
    required this.snapshot,
  });

  final ConnectivitySnapshot snapshot;

  LinearGradient _getGradient() {
    return snapshot.state == ConnectivityState.lowConnection
        ? ModernAppTheme.warningGradient
        : ModernAppTheme.dangerGradient;
  }

  String _getMessage() {
    return snapshot.state == ConnectivityState.lowConnection
        ? 'Conexión lenta'
        : 'Sin conexión';
  }

  String _getSubtitle() {
    return snapshot.state == ConnectivityState.lowConnection
        ? 'Operaciones en modo local'
        : 'Modo offline activo';
  }

  IconData _getIcon() {
    return snapshot.state == ConnectivityState.lowConnection
        ? Icons.wifi_tethering_error_rounded
        : Icons.wifi_off_rounded;
  }

  /// Calcula el nivel de señal basado en latencia y tasa de fallos
  int _getSignalLevel() {
    if (snapshot.state == ConnectivityState.offline) {
      return 0;
    }

    final latency = snapshot.latencyMs ?? 5000;
    final failureRate = snapshot.failureRate;

    // Calcula score basado en latencia (0-100)
    final latencyScore = ((1200 - latency.clamp(0, 1200)) / 1200 * 100).toInt();

    // Ajusta por tasa de fallos
    final adjustedScore = (latencyScore * (1 - failureRate)).toInt();

    if (adjustedScore >= 75) return 4;
    if (adjustedScore >= 50) return 3;
    if (adjustedScore >= 25) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = snapshot.state != ConnectivityState.onlineStable;
    final signalLevel = _getSignalLevel();
    final hasLatency = snapshot.latencyMs != null;

    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, -1.2),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: _getGradient(),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: (snapshot.state == ConnectivityState.lowConnection
                        ? ModernAppTheme.warningOrangeDark
                        : ModernAppTheme.dangerRedDark)
                    .withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ModernAppTheme.paddingLarge,
              vertical: ModernAppTheme.paddingMedium,
            ),
            child: Row(
              children: [
                // Icono principal
                Icon(
                  _getIcon(),
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: ModernAppTheme.paddingLarge),

                // Contenido texto
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getMessage(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0.2,
                          height: 1.2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getSubtitle(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.90),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          height: 1.3,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: ModernAppTheme.paddingLarge),

                // Indicador de calidad (señal + latencia)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Barras de señal
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 2.5,
                      children: List.generate(
                        4,
                        (index) => Container(
                          width: 2.5,
                          height: 6 + (index * 2.5).toDouble(),
                          decoration: BoxDecoration(
                            color: index < signalLevel
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(1.2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Latencia
                    if (hasLatency)
                      Text(
                        '${snapshot.latencyMs}ms',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.90),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          height: 1.2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
