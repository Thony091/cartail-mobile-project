class ReservationNotFound implements Exception {}

class ReservationCreateError implements Exception {
  final String message;
  ReservationCreateError(this.message);
}

class ReservationUpdateError implements Exception {
  final String message;
  ReservationUpdateError(this.message);
}

class ReservationDeleteError implements Exception {
  final String message;
  ReservationDeleteError(this.message);
}

class ReservationFetchError implements Exception {
  final String message;
  ReservationFetchError(this.message);
}

class ReservationConflict implements Exception {
  final String message;
  ReservationConflict(this.message);
}

class InvalidReservationDate implements Exception {
  final String message;
  InvalidReservationDate(this.message);
}

class ReservationSlotNotAvailable implements Exception {
  final String message;
  ReservationSlotNotAvailable(this.message);
}
