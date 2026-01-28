import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../../features/payment/data/models/credit_card_model.dart';
import '../../../features/shared/data/models/isar_domain_models.dart';
import '../../../features/sync_queue/data/models/sync_queue_item_model.dart';

/// Servicio singleton para gestionar la base de datos Isar
class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  Isar? _isar;
  bool _initialized = false;

  /// Obtiene la instancia de Isar
  Isar get isar {
    if (_isar == null || !_initialized) {
      throw Exception('IsarService no inicializado. Llama a init() primero.');
    }
    return _isar!;
  }

  /// Inicializa la base de datos Isar
  Future<void> init() async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [
        CreditCardModelSchema,
        UserModelSchema,
        ServiceModelSchema,
        VehicleModelSchema,
        SlotModelSchema,
        ReservationModelSchema,
        TicketModelSchema,
        SyncQueueItemModelSchema,
        // Aquí se pueden agregar más esquemas en el futuro
      ],
      directory: dir.path,
      name: 'portafolio_db',
      inspector: true, // Habilita el inspector de Isar (solo para desarrollo)
    );

    _initialized = true;
  }

  /// Cierra la base de datos
  Future<void> close() async {
    await _isar?.close();
    _initialized = false;
    _isar = null;
  }

  /// Limpia toda la base de datos (útil para testing o reset)
  Future<void> clearAll() async {
    if (_isar != null) {
      await _isar!.writeTxn(() async {
        await _isar!.clear();
      });
    }
  }

  /// Verifica si el servicio está inicializado
  bool get isInitialized => _initialized;
}
