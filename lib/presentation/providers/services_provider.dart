import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../presentation_container.dart';

final servicesProvider = StateNotifierProvider<ServicesNotifier, ServicesState>((ref) {

  final servicesRepository = ref.watch( servicesRepositoryProvider );

  return ServicesNotifier(
    servicesRepository: servicesRepository
  );
});

class ServicesNotifier extends StateNotifier<ServicesState>{

  final ServicesRepository servicesRepository;

  ServicesNotifier({
    required this.servicesRepository
  }) : super(ServicesState()){
    getServices();
  }
  
  Future<bool> createOrUpdateService( Map<String, dynamic> serviceSimilar) async {

    try {
      
      final service = await servicesRepository.createUpdateService(serviceSimilar);
      final isServiceInList = state.services.any((element) => element.id == service.id);

      if ( !isServiceInList){
        state = state.copyWith(
          services: [...state.services, service]
        );
        return true;
      } 

      state = state.copyWith(
        services: state.services.map(
          (element) => ( element.id == service.id ) ? service : element
        ).toList()
      );
      return true;
      
    } catch (e) {
      return false;
    }

  }

  Future<bool> deleteService( String id ) async {

    try {
      
      await servicesRepository.deleteService(id);
      state = state.copyWith(
        services: state.services.where((element) => element.id != id).toList()
      );
      return true;
    } catch (e) {
      debugPrint('Error al eliminar el servicio: $e');
      return false;
    }

  }

  Future<void> getServices() async {
    
    state = state.copyWith(isLoading: true);

    try {
      
      final services = await servicesRepository.getServices();
      
      state = state.copyWith(
        services: services,
        isLoading: false
      );

    } catch (e) {
      
      state = state.copyWith(
        isLoading: false,
        error: 'Error al obtener los servicios'
      );

    }
  }
}

class ServicesState{

  final List<Services> services;
  final bool isLoading;
  final String error;

  ServicesState({
    this.services = const [],
    this.isLoading = false,
    this.error = ''
  });

  ServicesState copyWith({
    List<Services>? services,
    bool? isLoading,
    String? error
  }) => ServicesState(
    services: services ?? this.services,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error
  );

}