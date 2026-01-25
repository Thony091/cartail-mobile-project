import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/services.dart';
import '../../domain/repositories/services_repository.dart';
import '../../../../presentation/presentation_container.dart';

final servicesProvider = StateNotifierProvider<ServicesNotifier, ServicesState>((ref) {

  final servicesRepository = ref.watch( servicesRepositoryProvider );

  return ServicesNotifier(
    servicesRepository: servicesRepository
  );
});

final servicesFiltersProvider =
    StateNotifierProvider<ServicesFiltersNotifier, ServicesFiltersState>((ref) {
  return ServicesFiltersNotifier();
});

class ServicesNotifier extends StateNotifier<ServicesState>{

  final ServicesRepository servicesRepository;

  ServicesNotifier({
    required this.servicesRepository
  }) : super(ServicesState()){
    getServices();
  }
  
  Future<bool> createOrUpdateService( Map<String, dynamic> serviceSimilar) async {
    final service = await servicesRepository.createUpdateService(serviceSimilar);
    if (service.id.isEmpty) {
      await getServices();
      return true;
    }
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

class ServicesFiltersNotifier extends StateNotifier<ServicesFiltersState> {
  Timer? _debounce;

  ServicesFiltersNotifier() : super(ServicesFiltersState());

  void startSearch() {
    state = state.copyWith(isSearching: true);
  }

  void stopSearch() {
    _debounce?.cancel();
    state = state.copyWith(
      isSearching: false,
      searchQuery: '',
    );
  }

  void setSearchQuery(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      state = state.copyWith(searchQuery: value);
    });
  }

  void setCategoryId(int value) {
    state = state.copyWith(selectedCategoryId: value);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
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

class ServicesFiltersState {
  final String searchQuery;
  final int selectedCategoryId;
  final bool isSearching;

  ServicesFiltersState({
    this.searchQuery = '',
    this.selectedCategoryId = 0,
    this.isSearching = false,
  });

  ServicesFiltersState copyWith({
    String? searchQuery,
    int? selectedCategoryId,
    bool? isSearching,
  }) => ServicesFiltersState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      isSearching: isSearching ?? this.isSearching,
    );
}
