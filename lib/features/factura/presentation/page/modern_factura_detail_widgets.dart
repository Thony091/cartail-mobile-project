import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/factura.dart';
import '../providers/factura_form_provider.dart';
import '../providers/factura_provider.dart';
import '../../../shared/presentation/shared/widgets/widgets.dart';
import '../../../../config/services/helpers/formats.dart';

class FacturaFormFields extends ConsumerWidget {
  final Factura factura;
  final bool isEditMode;

  const FacturaFormFields({
    super.key,
    required this.factura,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(facturaFormProvider(factura));
    final formNotifier = ref.read(facturaFormProvider(factura).notifier);

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  color: Color(0xFF667eea),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Información de Factura',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                if (isEditMode) ...[
                  const SizedBox(width: 6),
                  const Text(
                    '*',
                    style: TextStyle(
                      color: Color(0xFFe74c3c),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            if (isEditMode) ...[
              ModernInputField(
                label: 'Identificador de Factura',
                hint: 'Ej: FAC-2026-001',
                initialValue: formState.identificadorFactura.value,
                onChanged: formNotifier.onIdentificadorFacturaChange,
              ),
              const SizedBox(height: 16),
              ModernInputField(
                label: 'Fecha de Emisión (YYYY-MM-DD)',
                hint: '2026-01-24',
                initialValue: formState.fechaEmision,
                onChanged: formNotifier.onFechaEmisionChange,
              ),
              const SizedBox(height: 16),
              ModernInputField(
                label: 'Subtotal',
                hint: 'Ej: 35000',
                keyboardType: TextInputType.number,
                initialValue: formState.subtotal.value.toString(),
                onChanged: (value) =>
                    formNotifier.onSubtotalChange(int.tryParse(value) ?? 0),
              ),
              const SizedBox(height: 16),
              ModernInputField(
                label: 'Impuesto',
                hint: 'Ej: 3500',
                keyboardType: TextInputType.number,
                initialValue: formState.impuesto.value.toString(),
                onChanged: (value) =>
                    formNotifier.onImpuestoChange(int.tryParse(value) ?? 0),
              ),
              const SizedBox(height: 16),
              ModernInputField(
                label: 'Total',
                hint: 'Ej: 38500',
                keyboardType: TextInputType.number,
                initialValue: formState.total.value.toString(),
                onChanged: (value) =>
                    formNotifier.onTotalChange(int.tryParse(value) ?? 0),
              ),
              const SizedBox(height: 16),
              ModernInputField(
                label: 'Estado',
                hint: 'Ej: Pagada',
                initialValue: formState.estado.value,
                onChanged: formNotifier.onEstadoChange,
              ),
              const SizedBox(height: 16),
              ModernInputField(
                label: 'ID Transacción',
                hint: 'Ej: 1',
                keyboardType: TextInputType.number,
                initialValue: formState.idTransaccion.toString(),
                onChanged: (value) =>
                    formNotifier.onIdTransaccionChange(int.tryParse(value) ?? 0),
              ),
              const SizedBox(height: 16),
              ModernInputField(
                label: 'URL PDF (opcional)',
                hint: 'https://...',
                initialValue: formState.pdf,
                onChanged: formNotifier.onPdfChange,
              ),
            ] else ...[
              _FacturaInfoRow(
                label: 'Identificador',
                value: formState.identificadorFactura.value.isEmpty
                    ? 'No definido'
                    : formState.identificadorFactura.value,
              ),
              _FacturaInfoRow(
                label: 'Estado',
                value: formState.estado.value.isEmpty
                    ? 'No definido'
                    : formState.estado.value,
              ),
              _FacturaInfoRow(
                label: 'Subtotal',
                value: '\$${Formats.formatPriceNumber(formState.subtotal.value)}',
              ),
              _FacturaInfoRow(
                label: 'Impuesto',
                value: '\$${Formats.formatPriceNumber(formState.impuesto.value)}',
              ),
              _FacturaInfoRow(
                label: 'Total',
                value: '\$${Formats.formatPriceNumber(formState.total.value)}',
              ),
              _FacturaInfoRow(
                label: 'Fecha',
                value: formState.fechaEmision,
              ),
              _FacturaInfoRow(
                label: 'Transacción',
                value: formState.idTransaccion.toString(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FacturaActionButtons extends ConsumerWidget {
  final Factura factura;

  const FacturaActionButtons({
    super.key,
    required this.factura,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(facturaFormProvider(factura));
    final formNotifier = ref.read(facturaFormProvider(factura).notifier);

    return Column(
      children: [
        ModernButton(
          text: factura.id == 'new' ? 'Crear Factura' : 'Guardar Cambios',
          isLoading: formState.isLoading,
          onPressed: () async {
            final success = await formNotifier.onFormSubmit();
            if (!context.mounted) return;
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    factura.id == 'new'
                        ? 'Factura creada correctamente'
                        : 'Factura actualizada',
                  ),
                ),
              );
              if (factura.id == 'new') {
                context.pop();
              }
            }
          },
        ),
        if (factura.id != 'new') ...[
          const SizedBox(height: 12),
          ModernButton(
            text: 'Eliminar Factura',
            style: ModernButtonStyle.danger,
            onPressed: () async {
              final confirmed = await _confirmDelete(context);
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
                context.pop();
              }
            },
          ),
        ],
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar factura'),
            content: const Text(
              '¿Seguro que deseas eliminar esta factura? Esta acción no se puede deshacer.',
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

class _FacturaInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _FacturaInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF7f8c8d),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2c3e50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
