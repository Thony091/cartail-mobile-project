class VehicleNotFound implements Exception {}

class VehicleCreateError implements Exception {
  final String message;
  VehicleCreateError(this.message);
}

class VehicleUpdateError implements Exception {
  final String message;
  VehicleUpdateError(this.message);
}

class VehicleDeleteError implements Exception {
  final String message;
  VehicleDeleteError(this.message);
}

class VehicleFetchError implements Exception {
  final String message;
  VehicleFetchError(this.message);
}
