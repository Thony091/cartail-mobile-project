import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'operator_checklist_templates.dart';

class OperatorChecklistEntry {
  final OperatorChecklistItemTemplate item;
  final bool isChecked;

  const OperatorChecklistEntry({
    required this.item,
    this.isChecked = false,
  });

  OperatorChecklistEntry copyWith({bool? isChecked}) {
    return OperatorChecklistEntry(
      item: item,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

class OperatorChecklistState {
  final String title;
  final List<OperatorChecklistEntry> entries;
  final List<String> checkedOrder;

  const OperatorChecklistState({
    required this.title,
    required this.entries,
    required this.checkedOrder,
  });

  bool get hasItems => entries.isNotEmpty;

  bool get requiredComplete {
    final requiredEntries = entries.where((e) => e.item.isRequired);
    if (requiredEntries.isEmpty) return true;
    return requiredEntries.every((entry) => entry.isChecked);
  }

  List<OperatorChecklistEntry> get checkedEntriesInOrder {
    return checkedOrder
        .map(
          (id) => entries.firstWhere(
            (entry) => entry.item.id == id,
            orElse: () => const OperatorChecklistEntry(
              item: OperatorChecklistItemTemplate(id: '', label: ''),
            ),
          ),
        )
        .where((entry) => entry.item.id.isNotEmpty)
        .toList();
  }
}

class OperatorChecklistController extends StateNotifier<OperatorChecklistState> {
  OperatorChecklistController(OperatorChecklistTemplate? template)
      : super(
          OperatorChecklistState(
            title: template?.title ?? 'Checklist',
            entries: template?.items
                    .map((item) => OperatorChecklistEntry(item: item))
                    .toList() ??
                const [],
            checkedOrder: const [],
          ),
        );

  void toggle(String id, bool isChecked) {
    final entries = state.entries.map((entry) {
      if (entry.item.id == id) {
        return entry.copyWith(isChecked: isChecked);
      }
      return entry;
    }).toList();

    final checkedOrder = [...state.checkedOrder];
    if (isChecked) {
      if (!checkedOrder.contains(id)) {
        checkedOrder.add(id);
      }
    } else {
      checkedOrder.remove(id);
    }

    state = OperatorChecklistState(
      title: state.title,
      entries: entries,
      checkedOrder: checkedOrder,
    );
  }
}

final operatorChecklistControllerProvider = StateNotifierProvider.autoDispose
    .family<OperatorChecklistController, OperatorChecklistState, int>(
  (ref, stateId) {
    final template = ref.watch(operatorChecklistTemplateByStateProvider(stateId));
    return OperatorChecklistController(template);
  },
);
