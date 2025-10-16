  import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';
import '../presentation_container.dart';

final workProvider = StateNotifierProvider.autoDispose.family<WorkNotifier, WorkState, String>(
  (ref, workId) {

    final workRepository = ref.watch( worksRepositoryProvider );

    return WorkNotifier(
      workRepository: workRepository,
      workId: workId
    );
  }
);

class WorkNotifier extends StateNotifier<WorkState>{

  final RealizedWorkRepository workRepository;

  WorkNotifier({
    required this.workRepository,
    required String workId,
  }) : super( WorkState( id: workId )){
    getWork();
  }

  Works newEmptyService(){
    return Works(
      id: 'new',
      name: '',
      description: '',
      image: ''
    );
  }

  Future<void> getWork() async {

    try {

      if( state.id == 'new' ){
        state = state.copyWith(
          work: newEmptyService(),
          isLoading: false
        );
        return;
      }
        
      final work = await workRepository.getRealizedWorkById(state.id);
      
      state = state.copyWith(
        work: work,
        isLoading: false
      );  

    } catch (e) {
      print('Error al obtener el servicio: $e');
    }
  }
    
  Future<void> deleteWork( String id ) async {

    try {
      
      await workRepository.deleteWork(id);
      state = state.copyWith(
        works: state.works.where((element) => element.id != id).toList()
      );

    } catch (e) {
      print(e);
    }

  }

}

class WorkState {

  final String id;
  final Works? work;
  final List<Works> works;
  final bool isLoading;
  final bool isSaving;

  WorkState({
    required this.id,
    this.work,
    this.works = const [],
    this.isLoading = true,
    this.isSaving = false,
  });

  WorkState copyWith({
    String? id,
    Works? work,
    List<Works>? works,
    bool? isLoading,
    bool? isSaving,
  }) => WorkState(
      id: id ?? this.id,
      work: work ?? this.work,
      works: works ?? this.works,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  
}  
  
