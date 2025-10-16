import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';
import '../presentation_container.dart';

final serviceProvider = StateNotifierProvider.autoDispose.family<ServiceNotifier, ServiceState, String>(
  (ref, serviceId) {

    final servicesRepository = ref.watch(servicesRepositoryProvider);

    return ServiceNotifier(
      servicesRepository: servicesRepository,
      serviceId: serviceId
    );
  }
);

class ServiceNotifier extends StateNotifier<ServiceState>{

  final ServicesRepository servicesRepository;

  ServiceNotifier({
    required this.servicesRepository,
    required String serviceId,
  }) : super( ServiceState( id: serviceId )){
    getService();
  }

  Services newEmptyService(){
    return Services(
      id: 'new',
      name: '',
      description: '',
      minPrice: 0,
      maxPrice: 0,
      isActive: false,
      images: []
    );
  }

  Future<void> getService() async {

    try {

      if( state.id == 'new' ){
        state = state.copyWith(
          service: newEmptyService(),
          isLoading: false
        );
        return;
      }
        
      final service = await servicesRepository.getServiceById(state.id);
      
      state = state.copyWith(
        service: service,
        isLoading: false
      );  

    } catch (e) {
      print('Error al obtener el servicio: $e');
    }
  }

}

class ServiceState {

  final String id;
  final Services? service;
  final bool isLoading;
  final bool isSaving;

  ServiceState({
    required this.id,
    this.service,
    this.isLoading = true,
    this.isSaving = false,
  });

  ServiceState copyWith({
    String? id,
    Services? service,
    bool? isLoading,
    bool? isSaving,
  }) => ServiceState(
      id: id ?? this.id,
      service: service ?? this.service,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  
}