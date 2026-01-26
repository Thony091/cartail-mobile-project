import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/works.dart';
import '../../domain/repositories/realized_work_repository.dart';
import '../../../../presentation/presentation_container.dart';

final worksProvider = StateNotifierProvider<WorksNotifier,  WorksState>((ref) {
  
  final worksRepository = ref.watch( worksRepositoryProvider );

  return WorksNotifier(worksRepository: worksRepository);
});

final worksFiltersProvider =
    StateNotifierProvider<WorksFiltersNotifier, WorksFiltersState>((ref) {
  return WorksFiltersNotifier();
});


class WorksNotifier extends StateNotifier<WorksState>{

  final RealizedWorkRepository worksRepository;

  WorksNotifier({
    required this.worksRepository
  }) : super( WorksState()){
    getWorks();
  }

  Future<void> getWorks() async {

    state = state.copyWith(loading: true);

    try {

      final works = await worksRepository.getRealizedWorks();

      state = state.copyWith(
        works: works, 
        loading: false
      );

    } catch (e) {
      state = state.copyWith(
        error: 'Error al obtener los trabajos', 
        loading: false
      );
    }
  }

  Future<void> deleteWork( String id ) async {

    try {
      
      await worksRepository.deleteWork(id);
      state = state.copyWith(
        works: state.works.where((element) => element.id != id).toList()
      );

    } catch (e) {
      print(e);
    }

  }

    Future<bool> createOrUpdateWork( Map<String, dynamic> workSimilar) async {

    try {
      
      final work = await worksRepository.createUpdateWorks(workSimilar);
      final isServiceInList = state.works.any((element) => element.id == work.id);

      if ( !isServiceInList){
        state = state.copyWith(
          works: [...state.works, work]
        );
        return true;
      } 

      state = state.copyWith(
        works: state.works.map(
          (element) => ( element.id == work.id ) ? work : element
        ).toList()
      );
      return true;
      
    } catch (e) {
      return false;
    }

  }


}


class WorksState{

  final List<Works> works;
  final bool loading;
  final String error;

  WorksState({
    this.works = const [], 
    this.loading = true, 
    this.error = '',
  });

  WorksState copyWith({
    List<Works>? works, 
    bool? loading, 
    String? error
  }) => WorksState(
      works: works ?? this.works,
      loading: loading ?? this.loading,
      error: error ?? this.error
    );
  

}

class WorksFiltersNotifier extends StateNotifier<WorksFiltersState> {
  Timer? _debounce;

  WorksFiltersNotifier() : super(WorksFiltersState());

  void startSearch() {
    state = state.copyWith(isSearching: true);
  }

  void stopSearch() {
    _debounce?.cancel();
    state = state.copyWith(isSearching: false, searchQuery: '');
  }

  void setSearchQuery(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      state = state.copyWith(searchQuery: value);
    });
  }

  void setCategory(String value) {
    state = state.copyWith(selectedCategory: value);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

class WorksFiltersState {
  final String searchQuery;
  final String selectedCategory;
  final bool isSearching;

  WorksFiltersState({
    this.searchQuery = '',
    this.selectedCategory = 'Todos',
    this.isSearching = false,
  });

  WorksFiltersState copyWith({
    String? searchQuery,
    String? selectedCategory,
    bool? isSearching,
  }) => WorksFiltersState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isSearching: isSearching ?? this.isSearching,
    );
}
