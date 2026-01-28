import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/services/storage/isar_service.dart';

/// Provider global de Isar para inyección de dependencias.
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});
