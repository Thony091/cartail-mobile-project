class SlotNotFound implements Exception {}

class SlotCreateError implements Exception {
  final String message;
  SlotCreateError(this.message);
}

class SlotUpdateError implements Exception {
  final String message;
  SlotUpdateError(this.message);
}

class SlotDeleteError implements Exception {
  final String message;
  SlotDeleteError(this.message);
}

class SlotFetchError implements Exception {
  final String message;
  SlotFetchError(this.message);
}

class SlotNotAvailable implements Exception {
  final String message;
  SlotNotAvailable(this.message);
}

class SlotConflict implements Exception {
  final String message;
  SlotConflict(this.message);
}
