import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../domain/entities/works.dart';
import '../../../../presentation/presentation_container.dart';

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
      title: Name.dirty( work.name ),
      description: Description.dirty(work.description),
      testimonial: Description.dirty(work.testimonial),
      rating: work.rating == 0 ? 1 : work.rating,
      isFeatured: work.isFeatured,
      isActive: work.isActive,
      date: work.date,
      vehicleModelId: work.vehicleModelId ?? 1,
      beforeImage: WorkImagen.dirty(work.beforeImage.isNotEmpty ? work.beforeImage : work.image),
      afterImage: WorkImagen.dirty(work.afterImage.isNotEmpty ? work.afterImage : work.image),
    ) 
  );

  onTitleChange( String value ) {
    final newTitle = Name.dirty(value);
    state = state.copyWith(
      title: newTitle,
      titleError: newTitle.errorMessage,
      isFormValid: _validate()
    );
  }

  onDescriptionChange( String value ) {
    final newDescription = Description.dirty(value);
    state = state.copyWith(
      description: newDescription,
      descriptionError: newDescription.errorMessage,
      isFormValid: _validate()
    );
  }

  onTestimonialChange( String value ) {
    final newTestimonial = Description.dirty(value);
    state = state.copyWith(
      testimonial: newTestimonial,
      testimonialError: newTestimonial.errorMessage,
      isFormValid: _validate()
    );
  }

  onRatingChange( int value ) {
    state = state.copyWith(
      rating: value,
      isFormValid: _validate()
    );
  }

  onDateChange( String value ) {
    state = state.copyWith(
      date: value,
      isFormValid: _validate()
    );
  }

  onVehicleModelIdChange( int value ) {
    state = state.copyWith(
      vehicleModelId: value,
      isFormValid: _validate()
    );
  }

  onIsFeaturedChange( bool value ) {
    state = state.copyWith(
      isFeatured: value,
    );
  }

  onIsActiveChange( bool value ) {
    state = state.copyWith(
      isActive: value,
    );
  }

  updateBeforeImage( String value ) {
    state = state.copyWith(
      beforeImage: WorkImagen.dirty(value),
      isFormValid: _validate()
    );
  }

  updateAfterImage( String value ) {
    state = state.copyWith(
      afterImage: WorkImagen.dirty(value),
      isFormValid: _validate()
    );
  }
  
  _tochedEverything(){
    final newTitle = Name.dirty(state.title.value);
    final newDescription = Description.dirty(state.description.value);
    final newTestimonial = Description.dirty(state.testimonial.value);

    state = state.copyWith(
      title: newTitle,
      description: newDescription,
      testimonial: newTestimonial,
      beforeImage: WorkImagen.dirty(state.beforeImage.value),
      afterImage: WorkImagen.dirty(state.afterImage.value),
      titleError: newTitle.errorMessage,
      descriptionError: newDescription.errorMessage,
      testimonialError: newTestimonial.errorMessage,
      isFormValid: _validate()
    );
  }

  Future<bool> onFormSubmit() async {

    _tochedEverything();
    if ( !state.isFormValid ) return false;
    if ( onSubmitCallback == null ) return false;

    state = state.copyWith(isLoading: true);

    final serviceSimilar = {
      'id': ( state.id == 'new' ) ? null : state.id,
      'titulo': state.title.value,
      'descripcion': state.description.value,
      'testimonio': state.testimonial.value,
      'calificacion': state.rating,
      'destacado': state.isFeatured,
      'activo': state.isActive,
      'fecha': state.date,
      'id_modelo_vehiculo': state.vehicleModelId,
      'imagen_antes': state.beforeImage.value,
      'imagen_despues': state.afterImage.value,
    };
    try {
      final result = await onSubmitCallback!(serviceSimilar);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  bool _validate() {
    final baseValid = Formz.validate([ 
      Name.dirty(state.title.value),
      Description.dirty(state.description.value),
      Description.dirty(state.testimonial.value),
      // WorkImagen.dirty(state.beforeImage.value),
      // WorkImagen.dirty(state.afterImage.value),
    ]);

    final hasDate = state.date.trim().isNotEmpty;
    final hasVehicleModel = state.vehicleModelId > 0;
    final hasRating = state.rating > 0;

    return baseValid && hasDate && hasVehicleModel && hasRating;
  }
}

class WorkFormState{

  final bool isFormValid;
  final bool isLoading;
  final String? id;
  final Name title;
  final Description description;
  final Description testimonial;
  final int rating;
  final bool isFeatured;
  final bool isActive;
  final String date;
  final int vehicleModelId;
  final WorkImagen beforeImage;
  final WorkImagen afterImage;
  final String? titleError;
  final String? descriptionError;
  final String? testimonialError;

  WorkFormState({
    required this.id,
    this.isFormValid  = false,
    this.isLoading    = false,
    this.title        = const Name.pure(),
    this.description  = const Description.pure(),
    this.testimonial  = const Description.pure(),
    this.rating       = 1,
    this.isFeatured   = false,
    this.isActive     = true,
    this.date         = '',
    this.vehicleModelId = 1,
    required this.beforeImage,
    required this.afterImage,
    this.titleError,
    this.descriptionError,
    this.testimonialError,
  });

  WorkFormState copyWith({
    bool? isFormValid,
    bool? isLoading,
    String? id,
    Name? title,
    Description? description,
    Description? testimonial,
    int? rating,
    bool? isFeatured,
    bool? isActive,
    String? date,
    int? vehicleModelId,
    WorkImagen? beforeImage,
    WorkImagen? afterImage,
    String? titleError,
    String? descriptionError,
    String? testimonialError,
  }) => WorkFormState(
    id: id ?? this.id,
    isFormValid: isFormValid ?? this.isFormValid,
    isLoading: isLoading ?? this.isLoading,
    title: title ?? this.title,
    description: description ?? this.description,
    testimonial: testimonial ?? this.testimonial,
    rating: rating ?? this.rating,
    isFeatured: isFeatured ?? this.isFeatured,
    isActive: isActive ?? this.isActive,
    date: date ?? this.date,
    vehicleModelId: vehicleModelId ?? this.vehicleModelId,
    beforeImage: beforeImage ?? this.beforeImage,
    afterImage: afterImage ?? this.afterImage,
    titleError: titleError ?? this.titleError,
    descriptionError: descriptionError ?? this.descriptionError,
    testimonialError: testimonialError ?? this.testimonialError,
  );

  @override
  String toString() {
    return '''
      WorkFormState:
        id: $id,
        isFormValid: $isFormValid,
        title: $title,
        description: $description,
        testimonial: $testimonial,
        rating: $rating,
        isFeatured: $isFeatured,
        isActive: $isActive,
        date: $date,
        vehicleModelId: $vehicleModelId,
        beforeImage: $beforeImage,
        afterImage: $afterImage,
    ''';
  }

}
