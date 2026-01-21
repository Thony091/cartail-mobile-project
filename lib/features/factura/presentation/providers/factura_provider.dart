import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/factura.dart';
import '../../domain/repositories/factura_repository.dart';
import 'factura_repository_provider.dart';

final facturaProvider = StateNotifierProvider<FacturaNotifier, FacturaState>((
  ref,
) {
  final facturaRepository = ref.watch(facturaRepositoryProvider);

  return FacturaNotifier(facturaRepository: facturaRepository);
});

class FacturaNotifier extends StateNotifier<FacturaState> {
  final FacturaRepository facturaRepository;

  FacturaNotifier({required this.facturaRepository}) : super(FacturaState()) {
    getFacturas();
  }

  Future<bool> createOrUpdateFactura(
    Map<String, dynamic> facturaSimilar,
  ) async {
    try {
      final factura = await facturaRepository.createUpdateFactura(
        facturaSimilar,
      );
      final isFacturaInList = state.facturas.any(
        (element) => element.id == factura.id,
      );

      if (!isFacturaInList) {
        state = state.copyWith(facturas: [...state.facturas, factura]);
        return true;
      }

      state = state.copyWith(
        facturas: state.facturas
            .map((element) => (element.id == factura.id) ? factura : element)
            .toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteFactura(String id) async {
    try {
      await facturaRepository.deleteFactura(id);
      state = state.copyWith(
        facturas: state.facturas.where((element) => element.id != id).toList(),
      );
      return true;
    } catch (e) {
      debugPrint('Error al eliminar la factura: $e');
      return false;
    }
  }

  Future<void> getFacturas() async {
    state = state.copyWith(isLoading: true);

    try {
      final facturas = await facturaRepository.getFacturas();

      state = state.copyWith(facturas: facturas, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al obtener las facturas',
      );
    }
  }
}

class FacturaState {
  final List<Factura> facturas;
  final bool isLoading;
  final String error;

  FacturaState({
    this.facturas = const [],
    this.isLoading = false,
    this.error = '',
  });

  FacturaState copyWith({
    List<Factura>? facturas,
    bool? isLoading,
    String? error,
  }) => FacturaState(
    facturas: facturas ?? this.facturas,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );
}
