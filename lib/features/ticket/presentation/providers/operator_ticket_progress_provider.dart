import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ticket.dart';
import '../../domain/usecases/ticket_checklist_usecase.dart';
import 'tickets_provider.dart';

class OperatorTicketProgressState {
  final int stateId;
  final List<String> template;
  final Set<int> checkedItems;
  final List<String> autoComments;
  final String manualComment;
  final String? errorMessage;
  final bool isSaving;

  const OperatorTicketProgressState({
    required this.stateId,
    required this.template,
    required this.checkedItems,
    required this.autoComments,
    required this.manualComment,
    required this.errorMessage,
    required this.isSaving,
  });

  OperatorTicketProgressState copyWith({
    int? stateId,
    List<String>? template,
    Set<int>? checkedItems,
    List<String>? autoComments,
    String? manualComment,
    String? errorMessage,
    bool? isSaving,
  }) {
    return OperatorTicketProgressState(
      stateId: stateId ?? this.stateId,
      template: template ?? this.template,
      checkedItems: checkedItems ?? this.checkedItems,
      autoComments: autoComments ?? this.autoComments,
      manualComment: manualComment ?? this.manualComment,
      errorMessage: errorMessage,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class OperatorTicketProgressNotifier
    extends StateNotifier<OperatorTicketProgressState> {
  final Ref ref;
  final TicketChecklistUsecase usecase;
  final Ticket ticket;

  OperatorTicketProgressNotifier({
    required this.ref,
    required this.usecase,
    required this.ticket,
  })
      : super(_initialState(ticket, usecase));

  static OperatorTicketProgressState _initialState(
    Ticket ticket,
    TicketChecklistUsecase usecase,
  ) {
    final stateId = ticket.estado.id;
    final template = usecase.templateForState(stateId);
    final checked = <int>{};
    final autoComments = usecase.buildAutoComments(template, checked);
    return OperatorTicketProgressState(
      stateId: stateId,
      template: template,
      checkedItems: checked,
      autoComments: autoComments,
      manualComment: '',
      errorMessage: null,
      isSaving: false,
    );
  }

  void toggleItem(int index, bool value) {
    final next = Set<int>.from(state.checkedItems);
    if (value) {
      next.add(index);
    } else {
      next.remove(index);
    }
    final autoComments = usecase.buildAutoComments(state.template, next);
    state = state.copyWith(
      checkedItems: next,
      autoComments: autoComments,
      errorMessage: null,
    );
  }

  void updateManualComment(String value) {
    state = state.copyWith(manualComment: value, errorMessage: null);
  }

  void changeState(int newStateId) {
    final template = usecase.templateForState(newStateId);
    state = state.copyWith(
      stateId: newStateId,
      template: template,
      checkedItems: <int>{},
      autoComments: const [],
      errorMessage: null,
    );
  }

  Future<bool> submitProgressUpdate({
    required Ticket ticket,
    required String operatorId,
    required String operatorName,
  }) async {
    final validationError = usecase.validateTransition(
      fromStateId: ticket.estado.id,
      toStateId: state.stateId,
      checkedIndices: state.checkedItems,
      template: state.template,
    );
    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      return false;
    }

    final manual = state.manualComment.trim();
    final comments = <String>[...state.autoComments];
    if (manual.isNotEmpty) {
      comments.add(manual);
    }

    state = state.copyWith(isSaving: true, errorMessage: null);
    final ok = await ref.read(ticketsProvider.notifier).updateTicketWithComments(
          ticket: ticket,
          stateId: state.stateId,
          comments: comments,
          authorId: operatorId,
          authorName: operatorName,
        );

    if (ok) {
      state = state.copyWith(
        manualComment: '',
        isSaving: false,
      );
    } else {
      state = state.copyWith(isSaving: false);
    }

    return ok;
  }
}

final operatorTicketProgressProvider = StateNotifierProvider.family<
    OperatorTicketProgressNotifier,
    OperatorTicketProgressState,
    Ticket>((ref, ticket) {
  const usecase = TicketChecklistUsecase();
  return OperatorTicketProgressNotifier(ref: ref, usecase: usecase, ticket: ticket);
});
