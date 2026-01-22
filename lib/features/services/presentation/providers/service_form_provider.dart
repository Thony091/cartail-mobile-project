import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../domain/entities/services.dart';
import '../../../../presentation/presentation_container.dart';
import '../../../category/presentation/providers/categories_provider.dart';

final serviceFormProvider = StateNotifierProvider.autoDispose.family<ServiceFormNotifier, ServiceFormState, Services>(
  (ref, services) {

    final createUpdateCallback = ref.watch( servicesProvider.notifier ).createOrUpdateService;

    // Obtener la categoría inicial si el servicio tiene categoryId
    String initialCategoryName = 'Detailing';
    if (services.categoryId != null) {
      final category = ref.read(categoryByIdProvider(services.categoryId!));
      if (category != null) {
        initialCategoryName = category.name;
      }
    }

    return ServiceFormNotifier(
      services: services,
      onSubmitCallback: createUpdateCallback,
      initialCategoryName: initialCategoryName,
      ref: ref,
    );
  }
);

class ServiceFormNotifier extends StateNotifier<ServiceFormState>{

  final Future<bool> Function( Map<String, dynamic> productSimilar )? onSubmitCallback;
  final Ref ref;

  ServiceFormNotifier({
    this.onSubmitCallback,
    required Services services,
    required String initialCategoryName,
    required this.ref,
  }): super(
    ServiceFormState(
      id: services.id,
      name: Name.dirty( services.name ),
      minPrice: Price.dirty( services.minPrice ),
      maxPrice: Price.dirty( services.maxPrice ),
      isActive: services.isActive,
      description: Description.dirty(services.description),
      images: services.images,
      durationMinutes: services.durationMinutes,
      requiresReservation: services.requiresReservation,
      selectedCategory: initialCategoryName,
      categoryId: services.categoryId,
    )
  );

  onNameChange( String value ) {
    state = state.copyWith(
      name: Name.dirty(value),
      isFormValid: Formz.validate([ 
        Name.dirty(value),
        Description.dirty(state.description.value),
        Price.dirty(state.minPrice.value),
        Price.dirty(state.maxPrice.value),
      ])
    );
  }

  onDescriptionChange( String value ) {
    state = state.copyWith(
      description: Description.dirty(value),
      isFormValid: Formz.validate([ 
        Name.dirty(state.name.value),
        Description.dirty(value),
        Price.dirty(state.minPrice.value),
        Price.dirty(state.maxPrice.value), 
      ])
    );
  }

  onMinPriceChange( int value ) {
    state = state.copyWith(
      minPrice: Price.dirty(value),
      isFormValid: Formz.validate([ 
        Name.dirty(state.name.value),
        Description.dirty(state.description.value),
        Price.dirty(value),
        Price.dirty(state.maxPrice.value),  
      ])
    );
  }

  onMaxPriceChange( int value ) {
    state = state.copyWith(
      maxPrice: Price.dirty(value),
      isFormValid: Formz.validate([ 
        Name.dirty(state.name.value),
        Description.dirty(state.description.value),
        Price.dirty(state.minPrice.value),
        Price.dirty(value),  
      ])
    );
  }
  

  onIsActiveChange( bool value ) {
    state = state.copyWith(
      isActive: value,
    );
  }

  onDurationChange( int value ) {
    state = state.copyWith(
      durationMinutes: value,
    );
  }

  onRequiresReservationChange( bool value ) {
    state = state.copyWith(
      requiresReservation: value,
    );
  }

  onCategoryChange( String categoryName ) {
    // Buscar la categoría por nombre para obtener el ID
    final category = ref.read(categoryByNameProvider(categoryName));

    state = state.copyWith(
      selectedCategory: categoryName,
      categoryId: category?.id,
    );
  }

  updateServiceImage( String value ) {
    state = state.copyWith(
      images: [ value ] // Solo una imagen según el backend
    );
  }

  setImages( List<String> images ) {
    state = state.copyWith(
      images: images,
    );
  }

  setIsLoading( bool isLoading ) {
    state = state.copyWith(
      isLoading: isLoading,
    );
  }

  _tochedEverything(){
    state = state.copyWith(
      isFormValid: Formz.validate([ 
        Name.dirty(state.name.value),
        Description.dirty(state.description.value),
        Price.dirty(state.minPrice.value),
        Price.dirty(state.maxPrice.value),  
      ])
    );
  }

  Future<bool> onFormSubmit() async {
    setIsLoading(true);
    _tochedEverything();
    if ( !state.isFormValid ) return false;
    if ( onSubmitCallback == null ) return false;

    final serviceSimilar = {
      'id': ( state.id == 'new' ) ? null : state.id,
      'nombre': state.name.value,
      'descripcion': state.description.value,
      'precio_min': state.minPrice.value,
      'precio_max': state.maxPrice.value,
      'activo': state.isActive,
      'images': state.images,
      'requiere_reserva': state.requiresReservation,
    };

    if (state.durationMinutes != 0) {
      serviceSimilar['duracion_minutos'] = state.durationMinutes;
    }

    // Agregar id_categoria si está disponible
    if (state.categoryId != null) {
      serviceSimilar['id_categoria'] = state.categoryId;
    }

    try {
      return await onSubmitCallback!(serviceSimilar).then((value) {
        setIsLoading(false);
        return value;
      });
    } catch (e) {
      return false;
    }
  }
}

class ServiceFormState{
  final bool isLoading;
  final bool isFormValid;
  final String? id;
  final Name name;
  final Description description;
  final Price minPrice;
  final Price maxPrice;
  final bool isActive;
  final List<String> images;
  final int durationMinutes;
  final bool requiresReservation;
  final String selectedCategory;
  final int? categoryId;

  ServiceFormState({
    this.isLoading = false,
    required this.id,
    this.isFormValid  = false,
    this.name         = const Name.pure(),
    this.minPrice     = const Price.pure(),
    this.maxPrice     = const Price.pure(),
    this.description  = const Description.pure(),
    this.isActive     = false,
    this.images       = const [],
    this.durationMinutes = 0,
    this.requiresReservation = false,
    this.selectedCategory = 'Detailing',
    this.categoryId,
  });

  ServiceFormState copyWith({
    bool? isLoading,
    bool? isFormValid,
    String? id,
    Name? name,
    Description? description,
    Price? minPrice,
    Price? maxPrice,
    bool? isActive,
    List<String>? images,
    int? durationMinutes,
    bool? requiresReservation,
    String? selectedCategory,
    int? categoryId,
  }) => ServiceFormState(
    isLoading: isLoading ?? this.isLoading,
    id: id ?? this.id,
    isFormValid: isFormValid ?? this.isFormValid,
    name: name ?? this.name,
    description: description ?? this.description,
    minPrice: minPrice ?? this.minPrice,
    maxPrice: maxPrice ?? this.maxPrice,
    isActive: isActive ?? this.isActive,
    images: images ?? this.images,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    requiresReservation: requiresReservation ?? this.requiresReservation,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    categoryId: categoryId ?? this.categoryId,
  );

  @override
  String toString() {
    return '''
      ServiceFormState:
        id: $id,
        isLoading: $isLoading,
        isFormValid: $isFormValid,
        name: $name,
        description: $description,
        minPrice: $minPrice,
        maxPrice: $maxPrice,
        isActive: $isActive,
        images: $images,
        durationMinutes: $durationMinutes,
        requiresReservation: $requiresReservation,
        selectedCategory: $selectedCategory,
        categoryId: $categoryId,
    ''';
  }

}
