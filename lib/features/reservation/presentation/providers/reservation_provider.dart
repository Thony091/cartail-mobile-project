
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import 'reservation_repository_provider.dart';

final reservationProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
  return ReservationNotifier(
    reservationRepository: ref.watch(reservationRepositoryProvider),
  );
});

class ReservationNotifier extends StateNotifier<ReservationState> {

  final ReservationRepository reservationRepository;

  ReservationNotifier({
    required this.reservationRepository
  }) : super(ReservationState()) {
    getReservations();
  }
  
  Future<void> getReservations() async {
    
    state = state.copyWith(isLoading: true);

    try {
      
      final reservations = await reservationRepository.getReservations();
      
      state = state.copyWith(
        reservations: reservations,
        isLoading: false
      );

    } catch (e) {
      
      state = state.copyWith(
        isLoading: false,
        error: 'Error al obtener las reservas'
      );

    }
  }

  Future<bool> createReservation( Map<String, dynamic> reservationSimilar ) async {
    
    state = state.copyWith(isLoading: true);

    try {
      
      final reservation = await reservationRepository.createUpdateReservation( 
        reservationSimilar 
      );
      
      state = state.copyWith(
        reservations: [...state.reservations, reservation],
        isLoading: false
      );
      return true;

    } catch (e) {
      
      state = state.copyWith(
        isLoading: false,
        error: 'Error al crear la reserva'
      );
      return false;

    }
  }

  Future<void> deleteReservation( String id ) async {
    try {
      await reservationRepository.deleteReservation(id);
      state = state.copyWith(
        reservations: state.reservations.where((element) => element.id != id).toList()
      );
    } catch (e) {
      throw Exception(e);
    }
  }


}

class ReservationState {

  final List<Reservation> reservations;
  final bool isLoading;
  final String error;

  ReservationState({
    this.reservations = const [],
    this.isLoading = false,
    this.error = ''
  });

  ReservationState copyWith({
    List<Reservation>? reservations,
    bool? isLoading,
    String? error
  }) => ReservationState(
    reservations: reservations ?? this.reservations,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error
  );

}
