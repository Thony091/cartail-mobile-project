

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../../domain/domain.dart';
import '../../presentation_container.dart';

final serviceFormProvider = StateNotifierProvider.autoDispose.family<ServiceFormNotifier, ServiceFormState, Services>(
  (ref, services) {

    final createUpdateCallback = ref.watch( servicesProvider.notifier ).createOrUpdateService;
  
    return ServiceFormNotifier(
      services: services,
      onSubmitCallback: createUpdateCallback,
    );
  }
);

class ServiceFormNotifier extends StateNotifier<ServiceFormState>{
  
  final Future<bool> Function( Map<String, dynamic> productSimilar )? onSubmitCallback;

  ServiceFormNotifier({
    this.onSubmitCallback,
    required Services services,
  }): super( 
    ServiceFormState(
      id: services.id,
      name: Name.dirty( services.name ),
      minPrice: Price.dirty( services.minPrice ),
      maxPrice: Price.dirty( services.maxPrice ),
      isActive: services.isActive,
      description: Description.dirty(services.description),
      images: services.images
    ) 
  );
  // }): super( ServiceFormState(id: '', name: Name.pure(), minPrice: Price.pure(), maxPrice: Price.pure(),isActive: false, description: '', images: []) );

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

  updateServiceImage( String value ) {
    state = state.copyWith(
      images: [ ...state.images, value ]
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
    
    _tochedEverything();
    if ( !state.isFormValid ) return false;
    if ( onSubmitCallback == null ) return false;
    final serviceSimilar = {
      'id': ( state.id == 'new' ) ? null : state.id,
      'name': state.name.value,
      'description': state.description.value,
      'minPrice': state.minPrice.value,
      'maxPrice': state.maxPrice.value,
      'isActive': state.isActive,
      'images': state.images
    };
    try {
      return await onSubmitCallback!(serviceSimilar);
    } catch (e) {
      return false;
    }
  }
}

class ServiceFormState{

  final bool isFormValid;
  final String? id;
  final Name name;
  final Description description;
  final Price minPrice;
  final Price maxPrice;
  final bool isActive; 
  final List<String> images;
  
  ServiceFormState({
    required this.id,
    this.isFormValid  = false,
    this.name         = const Name.pure(),
    this.minPrice     = const Price.pure(),
    this.maxPrice     = const Price.pure(),
    this.description  = const Description.pure(),
    this.isActive     = false,
    this.images       = const [],
  });

  ServiceFormState copyWith({
    bool? isFormValid,
    String? id,
    Name? name,
    Description? description,
    Price? minPrice,
    Price? maxPrice,
    bool? isActive,
    List<String>? images,
  }) => ServiceFormState(
    id: id ?? this.id,
    isFormValid: isFormValid ?? this.isFormValid,
    name: name ?? this.name,
    description: description ?? this.description,
    minPrice: minPrice ?? this.minPrice,
    maxPrice: maxPrice ?? this.maxPrice,
    isActive: isActive ?? this.isActive,
    images: images ?? this.images,
  );

  @override
  String toString() {
    return '''
      ServiceFormState:
        id: $id,
        isFormValid: $isFormValid,
        name: $name,
        description: $description,
        minPrice: $minPrice,
        maxPrice: $maxPrice,
        isActive: $isActive,
        images: $images,
    ''';
  }

}