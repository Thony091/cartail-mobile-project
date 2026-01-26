import '../config/ticket_checklist_templates.dart';

class TicketChecklistUsecase {
  const TicketChecklistUsecase();

  List<String> templateForState(int stateId) {
    return TicketChecklistRegistry.templateForState(stateId);
  }

  List<String> buildAutoComments(
    List<String> template,
    Set<int> checkedIndices,
  ) {
    final comments = <String>[];
    for (var i = 0; i < template.length; i++) {
      if (checkedIndices.contains(i)) {
        comments.add(template[i]);
      }
    }
    return comments;
  }

  String? validateTransition({
    required int fromStateId,
    required int toStateId,
    required Set<int> checkedIndices,
    required List<String> template,
  }) {
    if (toStateId == 3 && checkedIndices.isEmpty) {
      return 'Debes completar al menos un item antes de continuar.';
    }
    if ((toStateId == 4 || toStateId == 5) &&
        template.isNotEmpty &&
        checkedIndices.length < template.length) {
      return 'Debes completar todos los items antes de finalizar.';
    }
    return null;
  }
}
