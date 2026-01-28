import '../../../../shared/data/models/isar_domain_models.dart';

abstract class ReservationLocalDatasource {
  Future<ReservationModel?> getByBackendId(String backendId);
  Future<List<ReservationModel>> getByDate(String reservationDate);
  Future<List<ReservationModel>> getAll();
  Future<List<ReservationModel>> getUnsynced();
  Future<List<ReservationModel>> getUpdatedAfter(DateTime since);
  Future<void> upsert(ReservationModel model);
  Future<void> deleteByBackendId(String backendId);
  Future<void> clear();
}
