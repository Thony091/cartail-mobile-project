import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import 'vehicle_repository_provider.dart';

final vehicleProvider = StateNotifierProvider.autoDispose.family<VehicleNotifier, VehicleState, String>(
  (ref, vehicleId) {
    final vehicleRepository = ref.watch(vehicleRepositoryProvider);

    return VehicleNotifier(
      vehicleRepository: vehicleRepository,
      vehicleId: vehicleId,
    );
  },
);

class VehicleNotifier extends StateNotifier<VehicleState> {
  final VehicleRepository vehicleRepository;

  VehicleNotifier({
    required this.vehicleRepository,
    required String vehicleId,
  }) : super(VehicleState(id: vehicleId)) {
    getVehicle();
  }

  Vehicle newEmptyVehicle() {
    return Vehicle(
      id: 0,
      brand: '',
      model: '',
      year: '',
      trim: '',
    );
  }

  Future<void> getVehicle() async {
    try {
      if (state.id == 'new') {
        state = state.copyWith(
          vehicle: newEmptyVehicle(),
          isLoading: false,
        );
        return;
      }

      final vehicle = await vehicleRepository.getVehicleById(state.id);
      state = state.copyWith(
        vehicle: vehicle,
        isLoading: false,
      );
    } catch (e) {
      print('Error al obtener el modelo de vehículo: $e');
    }
  }
}

class VehicleState {
  final String id;
  final Vehicle? vehicle;
  final bool isLoading;
  final bool isSaving;

  VehicleState({
    required this.id,
    this.vehicle,
    this.isLoading = true,
    this.isSaving = false,
  });

  VehicleState copyWith({
    String? id,
    Vehicle? vehicle,
    bool? isLoading,
    bool? isSaving,
  }) => VehicleState(
      id: id ?? this.id,
      vehicle: vehicle ?? this.vehicle,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
}
