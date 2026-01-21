class TicketNotFound implements Exception {}

class TicketCreateError implements Exception {
  final String message;
  TicketCreateError(this.message);
}

class TicketUpdateError implements Exception {
  final String message;
  TicketUpdateError(this.message);
}

class TicketDeleteError implements Exception {
  final String message;
  TicketDeleteError(this.message);
}

class TicketFetchError implements Exception {
  final String message;
  TicketFetchError(this.message);
}

class TicketAssignmentError implements Exception {
  final String message;
  TicketAssignmentError(this.message);
}

class TicketStatusError implements Exception {
  final String message;
  TicketStatusError(this.message);
}

class TicketUnauthorizedAccess implements Exception {
  final String message;
  TicketUnauthorizedAccess(this.message);
}
