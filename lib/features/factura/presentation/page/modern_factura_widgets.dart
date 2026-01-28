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

  Color _getStatusColor() {
    final status = factura.estado.toLowerCase();
    if (status.contains('pagada') || status.contains('paid')) {
      return const Color(0xFF27ae60);
    } else if (status.contains('pendiente') || status.contains('pending')) {
      return const Color(0xFFf39c12);
    } else if (status.contains('cancelada') || status.contains('cancelled')) {
      return const Color(0xFFe74c3c);
    }
    return const Color(0xFF667eea);
  }

  IconData _getStatusIcon() {
    final status = factura.estado.toLowerCase();
    if (status.contains('pagada') || status.contains('paid')) {
      return Icons.check_circle;
    } else if (status.contains('pendiente') || status.contains('pending')) {
      return Icons.schedule;
    } else if (status.contains('cancelada') || status.contains('cancelled')) {
      return Icons.cancel;
    }
    return Icons.info;
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF667eea);

    return ModernCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con ícono y estado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        factura.identificadorFactura.isEmpty
                            ? 'Factura sin ID'
                            : factura.identificadorFactura,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(), size: 14, color: _getStatusColor()),
                      const SizedBox(width: 4),
                      Text(
                        factura.estado.isNotEmpty ? factura.estado : 'Sin estado',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Detalles de monto e impuestos
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.calculate_outlined,
                    'Subtotal',
                    '\$${Formats.formatPriceNumber(factura.subtotal)}',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.percent_outlined,
                    'Impuesto',
                    '\$${Formats.formatPriceNumber(factura.impuesto)}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Total destacado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF27ae60).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF27ae60).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  Text(
                    '\$${_formatTotal()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF27ae60),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ID de transacción
            Row(
              children: [
                const Icon(Icons.tag_outlined, size: 16, color: Color(0xFF7f8c8d)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'ID Transacción: ${factura.idTransaccion}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7f8c8d),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            if (trailing != null || factura.pdf.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (factura.pdf.isNotEmpty) ...[
                    Expanded(
                      child: ModernButton(
                        text: 'Ver PDF',
                        icon: Icons.picture_as_pdf,
                        style: ModernButtonStyle.secondary,
                        height: 36,
                        onPressed: onTap,
                      ),
                    ),
                  ] else ...[
                    const Spacer(),
                  ],
                  if (trailing != null) ...[
                    if (factura.pdf.isNotEmpty) const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF7f8c8d)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7f8c8d),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
        ),
      ],
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
