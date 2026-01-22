import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/services.dart';
import '../../domain/repositories/services_repository.dart';
import '../../../../presentation/presentation_container.dart';

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
      requiresReservation: false,
      isActive: true,
      images: [],
      durationMinutes: 0,
      categoryId: null,
    );
  }

  Future<void> getService() async {

    try {

      if( state.id == 'new' ){
        state = state.copyWith(
          service: newEmptyService(),
          isLoading: false,
          isEditMode: true,
        );
        return;
      }

      final service = await servicesRepository.getServiceById(state.id);

      state = state.copyWith(
        service: service,
        isLoading: false,
        selectedImages: service.images,
        name: service.name,
        description: service.description,
        minPrice: service.minPrice.toString(),
        maxPrice: service.maxPrice.toString(),
        duration: service.durationMinutes?.toString() ?? '',
        requiresReservation: service.requiresReservation,
        isActive: service.isActive,
      );

    } catch (e) {
      print('Error al obtener el servicio: $e');
    }
  }

  void setEditMode(bool isEditMode) {
    state = state.copyWith(isEditMode: isEditMode);
  }

  void setSelectedImages(List<String> images) {
    state = state.copyWith(selectedImages: images);
  }

  void setSaving(bool isSaving) {
    state = state.copyWith(isSaving: isSaving);
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setMinPrice(String minPrice) {
    state = state.copyWith(minPrice: minPrice);
  }

  void setMaxPrice(String maxPrice) {
    state = state.copyWith(maxPrice: maxPrice);
  }

  void setDuration(String duration) {
    state = state.copyWith(duration: duration);
  }

  void setRequiresReservation(bool requiresReservation) {
    state = state.copyWith(requiresReservation: requiresReservation);
  }

  void setIsActive(bool isActive) {
    state = state.copyWith(isActive: isActive);
  }

  void setSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

}

class ServiceState {

  final String id;
  final Services? service;
  final bool isLoading;
  final bool isSaving;
  final bool isEditMode;
  final List<String> selectedImages;

  // Form fields
  final String name;
  final String description;
  final String minPrice;
  final String maxPrice;
  final String duration;
  final bool requiresReservation;
  final bool isActive;
  final String selectedCategory;

  ServiceState({
    required this.id,
    this.service,
    this.isLoading = true,
    this.isSaving = false,
    this.isEditMode = false,
    this.selectedImages = const [],
    this.name = '',
    this.description = '',
    this.minPrice = '',
    this.maxPrice = '',
    this.duration = '',
    this.requiresReservation = false,
    this.isActive = true,
    this.selectedCategory = 'Detailing',
  });

  ServiceState copyWith({
    String? id,
    Services? service,
    bool? isLoading,
    bool? isSaving,
    bool? isEditMode,
    List<String>? selectedImages,
    String? name,
    String? description,
    String? minPrice,
    String? maxPrice,
    String? duration,
    bool? requiresReservation,
    bool? isActive,
    String? selectedCategory,
  }) => ServiceState(
      id: id ?? this.id,
      service: service ?? this.service,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isEditMode: isEditMode ?? this.isEditMode,
      selectedImages: selectedImages ?? this.selectedImages,
      name: name ?? this.name,
      description: description ?? this.description,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      duration: duration ?? this.duration,
      requiresReservation: requiresReservation ?? this.requiresReservation,
      isActive: isActive ?? this.isActive,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );

}