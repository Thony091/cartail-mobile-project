import '../../../../shared/data/models/isar_domain_models.dart';

abstract class TicketLocalDatasource {
  Future<TicketModel?> getByBackendId(String backendId);
  Future<List<TicketModel>> getByReservationId(String reservationId);
  Future<List<TicketModel>> getAll();
  Future<List<TicketModel>> getUnsynced();
  Future<void> upsert(TicketModel model);
  Future<void> upsertBatch(List<TicketModel> models);
  Future<void> clearAndUpsertBatch(List<TicketModel> models);
  Future<void> deleteByBackendId(String backendId);
  Future<void> clear();
}
