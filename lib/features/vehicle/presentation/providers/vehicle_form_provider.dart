import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../domain/entities/vehicle.dart';
import '../../../../presentation/presentation_container.dart';

final vehicleFormProvider = StateNotifierProvider.autoDispose.family<VehicleFormNotifier, VehicleFormState, Vehicle>(
  (ref, vehicle) {
    final createUpdateCallback = ref.watch(vehiclesProvider.notifier).createOrUpdateVehicle;

    return VehicleFormNotifier(
      vehicle: vehicle,
      onSubmitCallback: createUpdateCallback,
    );
  },
);

class VehicleFormNotifier extends StateNotifier<VehicleFormState> {
  final Future<Vehicle?> Function(Map<String, dynamic> vehicleSimilar)? onSubmitCallback;

  VehicleFormNotifier({
    this.onSubmitCallback,
    required Vehicle vehicle,
  }) : super(
          VehicleFormState(
            id: vehicle.id == 0 ? 'new' : vehicle.id.toString(),
            brand: Name.dirty(vehicle.brand),
            model: Name.dirty(vehicle.model),
            year: Name.dirty(vehicle.year),
            trim: Name.dirty(vehicle.trim),
            isYearValid: _isYearValidValue(vehicle.year),
          ),
        );

  void onBrandChange(String value) {
    state = state.copyWith(
      brand: Name.dirty(value),
      isFormValid: _validate(),
    );
  }

  void onModelChange(String value) {
    state = state.copyWith(
      model: Name.dirty(value),
      isFormValid: _validate(),
    );
  }

  void onYearChange(String value) {
    state = state.copyWith(
      year: Name.dirty(value),
      isYearValid: _isYearValidValue(value),
      isFormValid: _validate(),
    );
  }

  void onTrimChange(String value) {
    state = state.copyWith(
      trim: Name.dirty(value),
      isFormValid: _validate(),
    );
  }

  void _touchEverything() {
    state = state.copyWith(
      brand: Name.dirty(state.brand.value),
      model: Name.dirty(state.model.value),
      year: Name.dirty(state.year.value),
      trim: Name.dirty(state.trim.value),
      isYearValid: _isYearValidValue(state.year.value),
      isFormValid: _validate(),
    );
  }

  Future<bool> onFormSubmit() async {
    _touchEverything();
    if (!state.isFormValid) return false;
    if (onSubmitCallback == null) return false;

    state = state.copyWith(isLoading: true);

    final vehicleSimilar = {
      'id': (state.id == 'new') ? null : state.id,
      'marca': state.brand.value,
      'modelo': state.model.value,
      'anio': state.year.value,
      'trim': state.trim.value,
    };

    try {
      final result = await onSubmitCallback!(vehicleSimilar);
      state = state.copyWith(isLoading: false);
      return result != null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  bool _validate() {
    final baseValid = Formz.validate([
      Name.dirty(state.brand.value),
      Name.dirty(state.model.value),
      Name.dirty(state.year.value),
      Name.dirty(state.trim.value),
    ]);

    return baseValid && _isYearValidValue(state.year.value);
  }
}

bool _isYearValidValue(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;
  return RegExp(r'^\d{4}$').hasMatch(trimmed);
}

class VehicleFormState {
  final bool isFormValid;
  final bool isLoading;
  final String? id;
  final Name brand;
  final Name model;
  final Name year;
  final Name trim;
  final bool isYearValid;

  VehicleFormState({
    required this.id,
    this.isFormValid = false,
    this.isLoading = false,
    this.brand = const Name.pure(),
    this.model = const Name.pure(),
    this.year = const Name.pure(),
    this.trim = const Name.pure(),
    this.isYearValid = true,
  });

  VehicleFormState copyWith({
    bool? isFormValid,
    bool? isLoading,
    String? id,
    Name? brand,
    Name? model,
    Name? year,
    Name? trim,
    bool? isYearValid,
  }) => VehicleFormState(
      id: id ?? this.id,
      isFormValid: isFormValid ?? this.isFormValid,
      isLoading: isLoading ?? this.isLoading,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      trim: trim ?? this.trim,
      isYearValid: isYearValid ?? this.isYearValid,
    );
}
