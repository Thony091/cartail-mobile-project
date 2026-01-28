import '../../../shared/domain/entities/state.dart';
import '../../../shared/data/models/isar_domain_models.dart';
import '../../domain/entities/ticket_lookup.dart';

class TicketLookupMapper {
  static TicketLookup modelToEntity(TicketLookupModel model) {
    return TicketLookup(
      id: model.backendId,
      type: model.type,
      name: model.name,
      updatedAt: model.updatedAt,
    );
  }

  static TicketLookupModel entityToModel(TicketLookup entity) {
    return TicketLookupModel()
      ..key = '${entity.type}:${entity.id}'
      ..type = entity.type
      ..backendId = entity.id
      ..name = entity.name
      ..updatedAt = entity.updatedAt;
  }

  /// Convierte State (API response) a Entity
  static TicketLookup stateToEntity(State state, String type) {
    return TicketLookup(
      id: state.id,
      type: type,
      name: state.name,
      updatedAt: DateTime.now(),
    );
  }

  /// Convierte Entity a State (para usar con los dropdowns)
  static State entityToState(TicketLookup entity) {
    return State(id: entity.id, name: entity.name);
  }

  static List<TicketLookup> modelsToEntities(List<TicketLookupModel> models) {
    return models.map(modelToEntity).toList();
  }

  static List<TicketLookupModel> entitiesToModels(List<TicketLookup> entities) {
    return entities.map(entityToModel).toList();
  }

  static List<State> entitiesToStates(List<TicketLookup> entities) {
    return entities.map(entityToState).toList();
  }
}
