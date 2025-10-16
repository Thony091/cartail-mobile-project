

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../../domain/domain.dart';
import '../../presentation_container.dart';

final workFormProvider = StateNotifierProvider.autoDispose.family<WorkFormNotifier, WorkFormState, Works>(
  (ref, works) {

    final createUpdateCallback = ref.watch( worksProvider.notifier ).createOrUpdateWork;
  
    return WorkFormNotifier(
      work: works,
      onSubmitCallback: createUpdateCallback,
    );
  }
);

class WorkFormNotifier extends StateNotifier<WorkFormState>{
  
  final Future<bool> Function( Map<String, dynamic> productSimilar )? onSubmitCallback;

  WorkFormNotifier({
    this.onSubmitCallback,
    required Works work,
  }): super( 
    WorkFormState(
      id: work.id,
      name: Name.dirty( work.name ),
      description: Description.dirty(work.description),
      image: WorkImagen.dirty(work.image)
    ) 
  );

  onNameChange( String value ) {
    state = state.copyWith(
      name: Name.dirty(value),
      isFormValid: Formz.validate([ 
        Name.dirty(value),
        Description.dirty(state.description.value),
        WorkImagen.dirty(state.image.value),
      ])
    );
  }

  onDescriptionChange( String value ) {
    state = state.copyWith(
      description: Description.dirty(value),
      isFormValid: Formz.validate([ 
        Name.dirty(state.name.value),
        Description.dirty(value),
        WorkImagen.dirty(state.image.value),
      ])
    );
  }

  updateWorkImage( String value ) {
    state = state.copyWith(
      image: WorkImagen.dirty(value),
      isFormValid: Formz.validate([ 
        Name.dirty(state.name.value),
        Description.dirty(state.description.value),
        WorkImagen.dirty(value),
      ]) 
    );
  }
  
  _tochedEverything(){
    state = state.copyWith(
      isFormValid: Formz.validate([ 
        Name.dirty(state.name.value),
        Description.dirty(state.description.value),
        WorkImagen.dirty(state.image.value),
      ])
    );
  }

  Future<bool> onFormSubmit() async {
    
    _tochedEverything();
    if ( !state.isFormValid ) return false;
    if ( onSubmitCallback == null ) return false;
    final serviceSimilar = {
      'id': ( state.id == 'new' ) ? null : state.id,
      'name': state.name.value,
      'description': state.description.value,
      'image': state.image.value,
    };
    try {
      return await onSubmitCallback!(serviceSimilar);
    } catch (e) {
      return false;
    }
  }
}

class WorkFormState{

  final bool isFormValid;
  final String? id;
  final Name name;
  final Description description;
  final WorkImagen image;
  
  WorkFormState({
    required this.id,
    this.isFormValid  = false,
    this.name         = const Name.pure(),
    this.description  = const Description.pure(),
    required this.image,  
  });

  WorkFormState copyWith({
    bool? isFormValid,
    String? id,
    Name? name,
    Description? description,
    WorkImagen? image,
  }) => WorkFormState(
    id: id ?? this.id,
    isFormValid: isFormValid ?? this.isFormValid,
    name: name ?? this.name,
    description: description ?? this.description,
    image: image ?? this.image,
  );

  @override
  String toString() {
    return '''
      WorkFormState:
        id: $id,
        isFormValid: $isFormValid,
        name: $name,
        description: $description,
        image: $image,
    ''';
  }

}