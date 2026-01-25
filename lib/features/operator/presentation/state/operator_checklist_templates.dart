import 'package:flutter_riverpod/flutter_riverpod.dart';

class OperatorChecklistItemTemplate {
  final String id;
  final String label;
  final bool isRequired;

  const OperatorChecklistItemTemplate({
    required this.id,
    required this.label,
    this.isRequired = false,
  });
}

class OperatorChecklistTemplate {
  final int stateId;
  final String title;
  final List<OperatorChecklistItemTemplate> items;

  const OperatorChecklistTemplate({
    required this.stateId,
    required this.title,
    required this.items,
  });
}

final operatorChecklistTemplatesProvider = Provider<List<OperatorChecklistTemplate>>(
  (ref) {
    return const [
      OperatorChecklistTemplate(
        stateId: 2,
        title: 'Checklist de Recepcion',
        items: [
          OperatorChecklistItemTemplate(
            id: 'reception-1',
            label: 'Vehiculo recibido en area de trabajo',
            isRequired: true,
          ),
          OperatorChecklistItemTemplate(
            id: 'reception-2',
            label: 'Revision visual inicial completada',
          ),
          OperatorChecklistItemTemplate(
            id: 'reception-3',
            label: 'Herramientas basicas listas',
          ),
        ],
      ),
      OperatorChecklistTemplate(
        stateId: 3,
        title: 'Checklist de Trabajo',
        items: [
          OperatorChecklistItemTemplate(
            id: 'progress-1',
            label: 'Diagnostico inicial registrado',
            isRequired: true,
          ),
          OperatorChecklistItemTemplate(
            id: 'progress-2',
            label: 'Materiales generales confirmados',
          ),
          OperatorChecklistItemTemplate(
            id: 'progress-3',
            label: 'Area de trabajo asegurada',
          ),
        ],
      ),
      OperatorChecklistTemplate(
        stateId: 4,
        title: 'Checklist de Finalizacion',
        items: [
          OperatorChecklistItemTemplate(
            id: 'finish-1',
            label: 'Pruebas finales completadas',
            isRequired: true,
          ),
          OperatorChecklistItemTemplate(
            id: 'finish-2',
            label: 'Limpieza final realizada',
          ),
          OperatorChecklistItemTemplate(
            id: 'finish-3',
            label: 'Validacion final del trabajo',
          ),
        ],
      ),
      OperatorChecklistTemplate(
        stateId: 5,
        title: 'Checklist de Aprobacion',
        items: [
          OperatorChecklistItemTemplate(
            id: 'approval-1',
            label: 'Entrega validada con el cliente',
            isRequired: true,
          ),
          OperatorChecklistItemTemplate(
            id: 'approval-2',
            label: 'Comentarios finales registrados',
          ),
        ],
      ),
    ];
  },
);

final operatorChecklistTemplateByStateProvider = Provider.family<
    OperatorChecklistTemplate?,
    int>(
  (ref, stateId) {
    final templates = ref.watch(operatorChecklistTemplatesProvider);
    for (final template in templates) {
      if (template.stateId == stateId) {
        return template;
      }
    }
    return null;
  },
);
