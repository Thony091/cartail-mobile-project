import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/factura.dart';
import '../../domain/repositories/factura_repository.dart';
import 'factura_repository_provider.dart';

final facturaProvider = StateNotifierProvider<FacturaNotifier, FacturaState>((ref) {
  final facturaRepository = ref.watch(facturaRepositoryProvider);

  return FacturaNotifier(facturaRepository: facturaRepository);
});

final userFacturasProvider =
    StateNotifierProvider<UserFacturasNotifier, FacturaState>((ref) {
  final facturaRepository = ref.watch(facturaRepositoryProvider);

  return UserFacturasNotifier(
    facturaRepository: facturaRepository,
  );
});

final facturaByIdProvider =
    StateNotifierProvider.autoDispose.family<FacturaDetailNotifier, FacturaDetailState, String>(
  (ref, facturaId) {
    final facturaRepository = ref.watch(facturaRepositoryProvider);

    return FacturaDetailNotifier(
      facturaRepository: facturaRepository,
      facturaId: facturaId,
    );
  },
);

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

  Future<void> refreshFacturaById(String id) async {
    try {
      final factura = await facturaRepository.getFacturaById(id);
      final exists = state.facturas.any((item) => item.id == factura.id);
      if (exists) {
        state = state.copyWith(
          facturas: state.facturas
              .map((item) => item.id == factura.id ? factura : item)
              .toList(),
        );
      } else {
        state = state.copyWith(facturas: [...state.facturas, factura]);
      }
    } catch (e) {
      debugPrint('Error al obtener factura específica: $e');
    }
  }
}

class UserFacturasNotifier extends StateNotifier<FacturaState> {
  final FacturaRepository facturaRepository;

  UserFacturasNotifier({
    required this.facturaRepository,
  }) : super(FacturaState()) {
    getFacturasByUser();
  }

  Future<void> getFacturasByUser() async {
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

  Future<void> refreshFacturaById(String id) async {
    try {
      final factura = await facturaRepository.getFacturaById(id);
      final exists = state.facturas.any((item) => item.id == factura.id);
      if (exists) {
        state = state.copyWith(
          facturas: state.facturas
              .map((item) => item.id == factura.id ? factura : item)
              .toList(),
        );
      } else {
        state = state.copyWith(facturas: [...state.facturas, factura]);
      }
    } catch (e) {
      debugPrint('Error al obtener factura específica: $e');
    }
  }
}

class FacturaDetailNotifier extends StateNotifier<FacturaDetailState> {
  final FacturaRepository facturaRepository;

  FacturaDetailNotifier({
    required this.facturaRepository,
    required String facturaId,
  }) : super(FacturaDetailState(id: facturaId)) {
    getFactura();
  }

  Factura newEmptyFactura() {
    return Factura(
      id: 'new',
      identificadorFactura: '',
      fechaEmision: DateTime.now(),
      subtotal: 0,
      impuesto: 0,
      total: 0,
      estado: '',
      pdf: '',
      idTransaccion: 0,
    );
  }

  Future<void> getFactura() async {
    try {
      if (state.id == 'new') {
        state = state.copyWith(
          factura: newEmptyFactura(),
          isLoading: false,
          isEditMode: true,
        );
        return;
      }

      final factura = await facturaRepository.getFacturaById(state.id);
      state = state.copyWith(factura: factura, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setEditMode(bool isEditMode) {
    state = state.copyWith(isEditMode: isEditMode);
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

class FacturaDetailState {
  final String id;
  final Factura? factura;
  final bool isLoading;
  final bool isSaving;
  final bool isEditMode;

  FacturaDetailState({
    required this.id,
    this.factura,
    this.isLoading = true,
    this.isSaving = false,
    this.isEditMode = false,
  });

  FacturaDetailState copyWith({
    String? id,
    Factura? factura,
    bool? isLoading,
    bool? isSaving,
    bool? isEditMode,
  }) => FacturaDetailState(
      id: id ?? this.id,
      factura: factura ?? this.factura,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isEditMode: isEditMode ?? this.isEditMode,
    );
}
