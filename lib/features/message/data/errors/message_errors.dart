class MessageNotFound implements Exception {}

class MessageCreateError implements Exception {
  final String message;
  MessageCreateError(this.message);
}

class MessageUpdateError implements Exception {
  final String message;
  MessageUpdateError(this.message);
}

class MessageDeleteError implements Exception {
  final String message;
  MessageDeleteError(this.message);
}

class MessageFetchError implements Exception {
  final String message;
  MessageFetchError(this.message);
}

class InvalidMessageData implements Exception {
  final String message;
  InvalidMessageData(this.message);
}
