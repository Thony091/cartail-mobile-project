import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../domain/entities/factura.dart';
import '../../../../presentation/presentation_container.dart';
import 'factura_provider.dart';

final facturaFormProvider = StateNotifierProvider.autoDispose
    .family<FacturaFormNotifier, FacturaFormState, Factura>((ref, factura) {
  final createUpdateCallback =
      ref.watch(facturaProvider.notifier).createOrUpdateFactura;

  return FacturaFormNotifier(
    factura: factura,
    onSubmitCallback: createUpdateCallback,
  );
});

class FacturaFormNotifier extends StateNotifier<FacturaFormState> {
  final Future<bool> Function(Map<String, dynamic> facturaSimilar)?
  onSubmitCallback;

  FacturaFormNotifier({
    this.onSubmitCallback,
    required Factura factura,
  }) : super(
          FacturaFormState(
            id: factura.id,
            identificadorFactura:
                Description.dirty(factura.identificadorFactura),
            fechaEmision: _formatDate(factura.fechaEmision),
            subtotal: Price.dirty(factura.subtotal),
            impuesto: Price.dirty(factura.impuesto),
            total: Price.dirty(factura.total),
            estado: Description.dirty(factura.estado),
            pdf: factura.pdf,
            idTransaccion: factura.idTransaccion,
          ),
        );

  static String _formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }

  void onIdentificadorFacturaChange(String value) {
    state = state.copyWith(
      identificadorFactura: Description.dirty(value),
      isFormValid: _validate(),
    );
  }

  void onFechaEmisionChange(String value) {
    state = state.copyWith(
      fechaEmision: value,
      isFormValid: _validate(),
    );
  }

  void onSubtotalChange(int value) {
    state = state.copyWith(
      subtotal: Price.dirty(value),
      isFormValid: _validate(),
    );
  }

  void onImpuestoChange(int value) {
    state = state.copyWith(
      impuesto: Price.dirty(value),
      isFormValid: _validate(),
    );
  }

  void onTotalChange(int value) {
    state = state.copyWith(
      total: Price.dirty(value),
      isFormValid: _validate(),
    );
  }

  void onEstadoChange(String value) {
    state = state.copyWith(
      estado: Description.dirty(value),
      isFormValid: _validate(),
    );
  }

  void onPdfChange(String value) {
    state = state.copyWith(pdf: value);
  }

  void onIdTransaccionChange(int value) {
    state = state.copyWith(idTransaccion: value);
  }

  void _touchedEverything() {
    state = state.copyWith(
      identificadorFactura: Description.dirty(state.identificadorFactura.value),
      estado: Description.dirty(state.estado.value),
      subtotal: Price.dirty(state.subtotal.value),
      impuesto: Price.dirty(state.impuesto.value),
      total: Price.dirty(state.total.value),
      isFormValid: _validate(),
    );
  }

  Future<bool> onFormSubmit() async {
    _touchedEverything();
    if (!state.isFormValid) return false;
    if (onSubmitCallback == null) return false;

    state = state.copyWith(isLoading: true);

    final facturaSimilar = {
      'id': (state.id == 'new') ? null : state.id,
      'identificadorFactura': state.identificadorFactura.value,
      'fechaEmision': state.fechaEmision,
      'subtotal': state.subtotal.value,
      'impuesto': state.impuesto.value,
      'total': state.total.value,
      'estado': state.estado.value,
      'pdf': state.pdf.trim(),
      'idTransaccion': state.idTransaccion,
    };

    try {
      final result = await onSubmitCallback!(facturaSimilar);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  bool _validate() {
    final baseValid = Formz.validate([
      Description.dirty(state.identificadorFactura.value),
      Description.dirty(state.estado.value),
      Price.dirty(state.subtotal.value),
      Price.dirty(state.impuesto.value),
      Price.dirty(state.total.value),
    ]);

    final hasFecha = state.fechaEmision.trim().isNotEmpty;
    final hasTransaccion = state.idTransaccion > 0;

    return baseValid && hasFecha && hasTransaccion;
  }
}

class FacturaFormState {
  final bool isFormValid;
  final bool isLoading;
  final String? id;
  final Description identificadorFactura;
  final String fechaEmision;
  final Price subtotal;
  final Price impuesto;
  final Price total;
  final Description estado;
  final String pdf;
  final int idTransaccion;

  FacturaFormState({
    required this.id,
    this.isFormValid = false,
    this.isLoading = false,
    this.identificadorFactura = const Description.pure(),
    this.fechaEmision = '',
    this.subtotal = const Price.pure(),
    this.impuesto = const Price.pure(),
    this.total = const Price.pure(),
    this.estado = const Description.pure(),
    this.pdf = '',
    this.idTransaccion = 0,
  });

  FacturaFormState copyWith({
    bool? isFormValid,
    bool? isLoading,
    String? id,
    Description? identificadorFactura,
    String? fechaEmision,
    Price? subtotal,
    Price? impuesto,
    Price? total,
    Description? estado,
    String? pdf,
    int? idTransaccion,
  }) =>
      FacturaFormState(
        id: id ?? this.id,
        isFormValid: isFormValid ?? this.isFormValid,
        isLoading: isLoading ?? this.isLoading,
        identificadorFactura: identificadorFactura ?? this.identificadorFactura,
        fechaEmision: fechaEmision ?? this.fechaEmision,
        subtotal: subtotal ?? this.subtotal,
        impuesto: impuesto ?? this.impuesto,
        total: total ?? this.total,
        estado: estado ?? this.estado,
        pdf: pdf ?? this.pdf,
        idTransaccion: idTransaccion ?? this.idTransaccion,
      );

  @override
  String toString() {
    return '''
      FacturaFormState:
        id: $id,
        isFormValid: $isFormValid,
        identificadorFactura: $identificadorFactura,
        fechaEmision: $fechaEmision,
        subtotal: $subtotal,
        impuesto: $impuesto,
        total: $total,
        estado: $estado,
        pdf: $pdf,
        idTransaccion: $idTransaccion,
    ''';
  }
}
