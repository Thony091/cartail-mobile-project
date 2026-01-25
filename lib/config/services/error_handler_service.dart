/// Servicio centralizado para convertir excepciones en mensajes legibles
/// Se usa en todos los providers para estandarizar los mensajes de error
class ErrorHandlerService {
  /// Convierte una excepción en un mensaje de error legible y en español
  ///
  /// Maneja:
  /// - Excepciones estándar (Exception, SocketException, etc.)
  /// - Errores HTTP (401, 400, 413, 500, etc.)
  /// - Errores de red (Connection refused, timeout, etc.)
  /// - Mensajes muy largos (extrae solo la primera línea)
  static String readableError(Object error) {
    final message = error.toString();

    // Patrones comunes de excepciones y sus mensajes legibles
    const prefixes = [
      'Exception:',
      'SocketException:',
      'TimeoutException:',
      'FormatException:',
      'HttpException:',
      'DioException:',
    ];

    String cleanMessage = message;
    for (final prefix in prefixes) {
      if (cleanMessage.startsWith(prefix)) {
        cleanMessage = cleanMessage.substring(prefix.length).trim();
        break;
      }
    }

    // Si el mensaje es muy largo, mostrar solo la primera línea
    if (cleanMessage.contains('\n')) {
      cleanMessage = cleanMessage.split('\n').first.trim();
    }

    // Casos específicos de errores comunes
    if (cleanMessage.contains('Connection refused') ||
        cleanMessage.contains('Failed host lookup')) {
      return 'No se pudo conectar con el servidor. Verifica tu conexión a internet.';
    }
    if (cleanMessage.contains('timed out') ||
        cleanMessage.contains('Timeout')) {
      return 'La solicitud tardó demasiado. Intenta nuevamente.';
    }
    if (cleanMessage.contains('413') ||
        cleanMessage.contains('Payload too large')) {
      return 'La imagen es demasiado grande. Usa una imagen más pequeña.';
    }
    if (cleanMessage.contains('401') ||
        cleanMessage.contains('Unauthorized')) {
      return 'No tienes permiso para realizar esta acción.';
    }
    if (cleanMessage.contains('400') ||
        cleanMessage.contains('Bad Request')) {
      return 'Los datos enviados no son válidos. Verifica los campos.';
    }
    if (cleanMessage.contains('403') ||
        cleanMessage.contains('Forbidden')) {
      return 'Acceso denegado. No tienes permisos suficientes.';
    }
    if (cleanMessage.contains('404') ||
        cleanMessage.contains('Not Found')) {
      return 'El recurso solicitado no existe.';
    }
    if (cleanMessage.contains('500') ||
        cleanMessage.contains('Internal Server Error')) {
      return 'Error del servidor. Intenta más tarde.';
    }
    if (cleanMessage.contains('502') ||
        cleanMessage.contains('Bad Gateway')) {
      return 'Servicio no disponible. Intenta más tarde.';
    }
    if (cleanMessage.contains('503') ||
        cleanMessage.contains('Service Unavailable')) {
      return 'Servicio en mantenimiento. Intenta más tarde.';
    }

    return cleanMessage.isEmpty ? 'Error desconocido' : cleanMessage;
  }
}
