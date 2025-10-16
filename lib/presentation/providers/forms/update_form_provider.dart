

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../presentation_container.dart';

final updateFormProvider = StateNotifierProvider.autoDispose<UpdateFormNotifier,UpdateFormState>(
  (ref) {

  final updateUserCallback = ref.watch( authProvider.notifier ).updateDataToFirestore;

  return UpdateFormNotifier(
    updateUserCallback: updateUserCallback,
  );
});

class UpdateFormNotifier extends StateNotifier<UpdateFormState> {

  final Function( Map<String, String> userSimilar )? updateUserCallback;

  UpdateFormNotifier({
    this.updateUserCallback,
  }): super( 
    UpdateFormState() 
  );
  
  onNameChange( String value ) {
    final newName = Name.dirty(value);
    state = state.copyWith(
      name: newName,
      isValid: Formz.validate([ newName, state.name ])
    );
  }
  
  onBirthayChange( String value ) {
    final newBirthday = Birthday.dirty(value);
    state = state.copyWith(
      birthday: newBirthday,
      isValid: Formz.validate([ newBirthday, state.birthday ])
    );
  }

  onPhoneChange( String value ) {
    final newPhone = Phone.dirty(value);
    state = state.copyWith(
      phone: newPhone,
      isValid: Formz.validate([ newPhone, state.phone ])
    );
  }

  onBioChange( String value ) {
    final newBio = Description.dirty(value);
    state = state.copyWith(
      bio: newBio,
      isValid: Formz.validate([ newBio, state.bio ])
    );
  }

  onRutChange( String value ) {
    final newRut = Rut.dirty(value);
    state = state.copyWith(
      rut: newRut,
      isValid: Formz.validate([ newRut, state.rut ])
    );
  }
  


  Future<bool> onUpdateFormSubmit ( ) async {
    
    _touchEveryField();
    if ( !state.isValid ) return false;
    if ( updateUserCallback == null ) return false;
    final userSimilar = {
      'name': state.name.value,
      'birthday': state.birthday.value,
      'phone': state.phone.value,
      'bio': state.bio.value,
      'ProfileImage': '',
    };
    try {
      return await updateUserCallback!( userSimilar );
    } catch (e) {
      throw Exception("Error en actualizacion: ${e.toString()}");
    }

  }

  // Future<bool> onFormSubmit() async {

  //   try {
      
  //     _touchEveryField();

  //     if ( !state.isValid ) return false;

  //     state = state.copyWith(isPosting: true);


  //     state = state.copyWith(isPosting: false);

  //     return true;

  //   } catch (e) {
  //     e.toString();
  //     return false;
  //   }
  // }

  _touchEveryField() {

    // final name     = Name.dirty(state.name.value);
    // final rut      = Rut.dirty(state.rut.value);
    // final birthday = Birthday.dirty(state.birthday.value);
    // final phone    = Phone.dirty(state.phone.value);

    state = state.copyWith(
      isFormPosted: true,
      // name: name,
      // rut: rut,
      // birthday: birthday,
      // phone: phone,
      isValid: Formz.validate([ 
        // name, 
        // rut, 
        // birthday, 
        // phone, 
      ])
    );

  }

}

class UpdateFormState {

  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Name name;
  final Rut rut;
  final Birthday birthday;
  final Phone phone;
  final Description bio;

  UpdateFormState({
    this.isPosting      = false,
    this.isFormPosted   = false,
    this.isValid        = false,
    this.name           = const Name.pure(),
    this.rut            = const Rut.pure(),
    this.birthday       = const Birthday.pure(),
    this.phone          = const Phone.pure(),
    this.bio            = const Description.pure()
  });

  UpdateFormState copyWith({
    bool?       isPosting,
    bool?       isFormPosted,
    bool?       isValid,
    Name?       name,
    Rut?        rut,
    Birthday?   birthday,
    Phone?      phone,
    Description?        bio,
  }) => UpdateFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    name: name ?? this.name,
    rut: rut ?? this.rut,
    birthday: birthday ?? this.birthday,
    phone: phone ?? this.phone,
    bio: bio ?? this.bio,
  );

  @override
  String toString() {
    return '''
      UpdateFormState:
        isPosting: $isPosting
        isFormPosted: $isFormPosted
        isValid: $isValid
        name: $name
        rut: $rut
        birthday: $birthday
        phone: $phone
        bio: $bio
    ''';
  }
}
