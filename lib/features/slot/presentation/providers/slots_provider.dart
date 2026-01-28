import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/slot.dart';
import '../../domain/repositories/slot_repository.dart';
import 'slot_repository_provider.dart';

final slotsProvider = StateNotifierProvider<SlotsNotifier, SlotsState>((ref) {
  final slotRepository = ref.watch(slotRepositoryProvider);
  return SlotsNotifier(slotRepository: slotRepository);
});

class SlotsNotifier extends StateNotifier<SlotsState> {
  final SlotRepository slotRepository;

  SlotsNotifier({required this.slotRepository}) : super(SlotsState()) {
    getSlots();
  }

  Future<void> getSlots() async {
    try {
      state = state.copyWith(isLoading: true);
      final slots = await slotRepository.getSlots();
      state = state.copyWith(
        slots: slots,
        isLoading: false,
        error: '',
      );
    } catch (e) {
      debugPrint('Error al obtener slots: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar los slots',
      );
    }
  }

  Future<void> refresh() async {
    await getSlots();
  }
}

class SlotsState {
  final List<Slot> slots;
  final bool isLoading;
  final String error;

  SlotsState({
    this.slots = const [],
    this.isLoading = false,
    this.error = '',
  });

  SlotsState copyWith({
    List<Slot>? slots,
    bool? isLoading,
    String? error,
  }) =>
      SlotsState(
        slots: slots ?? this.slots,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}
