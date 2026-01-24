import 'package:flutter/material.dart';

import '../../domain/entities/factura.dart';
import '../../../shared/presentation/shared/widgets/widgets.dart';
import '../../../../config/services/helpers/formats.dart';

class FacturaSummaryCard extends StatelessWidget {
  final Factura factura;
  final VoidCallback? onTap;
  final Widget? trailing;

  const FacturaSummaryCard({
    super.key,
    required this.factura,
    this.onTap,
    this.trailing,
  });

  String _formatTotal() {
    return Formats.formatPriceNumber(factura.total);
  }

  String _formatDate() {
    final date = factura.fechaEmision;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Color(0xFF667eea),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      factura.identificadorFactura.isEmpty
                          ? 'Factura sin identificador'
                          : factura.identificadorFactura,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Total: \$${_formatTotal()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF27ae60),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _InfoChip(
                          icon: Icons.calendar_today_outlined,
                          label: _formatDate(),
                        ),
                        _InfoChip(
                          icon: Icons.tag,
                          label: 'Transacción ${factura.idTransaccion}',
                        ),
                        if (factura.estado.isNotEmpty)
                          _InfoChip(
                            icon: Icons.verified_outlined,
                            label: factura.estado,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyFacturasView extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onAction;
  final String actionLabel;

  const EmptyFacturasView({
    super.key,
    this.title = 'Sin facturas disponibles',
    this.subtitle = 'Aún no hay facturas para mostrar en este momento.',
    this.onAction,
    this.actionLabel = 'Crear factura',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.receipt_long,
                size: 48,
                color: Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF7f8c8d),
                fontSize: 14,
              ),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 20),
              ModernButton(
                text: actionLabel,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFeef2ff),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF667eea)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF667eea),
            ),
          ),
        ],
      ),
    );
  }
}
