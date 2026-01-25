import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ticket/domain/entities/ticket.dart';
import '../../../ticket/presentation/providers/tickets_provider.dart';
import '../../../state/presentation/providers/states_provider.dart';

class OperatorTicketController {
  final Ref ref;

  OperatorTicketController(this.ref);

  int? nextStateId(int currentStateId) {
    final states = [...ref.read(statesProvider)];
    states.sort((a, b) => a.id.compareTo(b.id));
    final index = states.indexWhere((state) => state.id == currentStateId);
    if (index == -1 || index == states.length - 1) {
      return null;
    }
    return states[index + 1].id;
  }

  Future<bool> updateTicketWithNotes({
    required Ticket ticket,
    required int nextStateId,
    required String notes,
    required String authorId,
    required String authorName,
  }) async {
    if (notes.trim().isEmpty) {
      return ref.read(ticketsProvider.notifier).updateTicketStatus(
            ticket: ticket,
            stateId: nextStateId,
          );
    }

    final updatedTicket = _appendComment(
      ticket: ticket,
      comment: notes.trim(),
      authorId: authorId,
      authorName: authorName,
    ).copyWith(stateId: nextStateId);

    return ref.read(ticketsProvider.notifier).updateTicket(updatedTicket);
  }

  Ticket _appendComment({
    required Ticket ticket,
    required String comment,
    required String authorId,
    required String authorName,
  }) {
    final now = DateTime.now().toIso8601String();
    final existing = ticket.metadata['comments'];
    final List<Map<String, dynamic>> comments = [];
    if (existing is List) {
      for (final item in existing) {
        if (item is Map<String, dynamic>) {
          comments.add(Map<String, dynamic>.from(item));
        }
      }
    }
    comments.add({
      'message': comment,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': now,
    });

    return ticket.copyWith(
      metadata: {
        ...ticket.metadata,
        'comments': comments,
      },
    );
  }
}

final operatorTicketControllerProvider = Provider<OperatorTicketController>(
  (ref) => OperatorTicketController(ref),
);
