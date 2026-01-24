import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import 'vehicle_repository_provider.dart';

final vehiclesProvider = StateNotifierProvider<VehiclesNotifier, VehiclesState>((ref) {
  final vehicleRepository = ref.watch(vehicleRepositoryProvider);
  return VehiclesNotifier(vehicleRepository: vehicleRepository);
});

class VehiclesNotifier extends StateNotifier<VehiclesState> {
  final VehicleRepository vehicleRepository;

  VehiclesNotifier({required this.vehicleRepository}) : super(VehiclesState()) {
    getVehicles();
  }

  Future<void> getVehicles() async {
    state = state.copyWith(loading: true, error: '');

    try {
      final vehicles = await vehicleRepository.getVehicles();
      state = state.copyWith(vehicles: vehicles, loading: false);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Error al obtener los modelos de vehículo',
      );
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      await vehicleRepository.deleteVehicle(id);
      state = state.copyWith(
        vehicles: state.vehicles.where((element) => element.id.toString() != id).toList(),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<Vehicle?> createOrUpdateVehicle(Map<String, dynamic> vehicleSimilar) async {
    try {
      final vehicle = await vehicleRepository.createUpdateVehicle(vehicleSimilar);
      final isInList = state.vehicles.any((element) => element.id == vehicle.id);

      if (!isInList) {
        state = state.copyWith(vehicles: [...state.vehicles, vehicle]);
        return vehicle;
      }

      state = state.copyWith(
        vehicles: state.vehicles
            .map((element) => (element.id == vehicle.id) ? vehicle : element)
            .toList(),
      );
      return vehicle;
    } catch (e) {
      return null;
    }
  }
}

class VehiclesState {
  final List<Vehicle> vehicles;
  final bool loading;
  final String error;

  VehiclesState({
    this.vehicles = const [],
    this.loading = true,
    this.error = '',
  });

  VehiclesState copyWith({
    List<Vehicle>? vehicles,
    bool? loading,
    String? error,
  }) => VehiclesState(
      vehicles: vehicles ?? this.vehicles,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
}
