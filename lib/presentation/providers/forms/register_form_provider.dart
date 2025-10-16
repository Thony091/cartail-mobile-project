

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../presentation_container.dart';

final registerFormProvider = StateNotifierProvider.autoDispose<RegisterFormNotifier,RegisterFormState>((ref) {

  final registerUserCallback = ref.watch( authProvider.notifier ).registerUserFireBase;

  return RegisterFormNotifier(
    registerUserCallback:registerUserCallback
  );
});

class RegisterFormNotifier extends StateNotifier<RegisterFormState> {

  final Function(String, String, String, String, String, String) registerUserCallback;

  RegisterFormNotifier({
    required this.registerUserCallback,
  }): super( RegisterFormState() );
  
  onNameChange( String value ) {
    final newName = Name.dirty(value);
    state = state.copyWith(
      name: newName,
      isValid: Formz.validate([ newName, state.name ])
    );
  }
  
  onRutChange( String value ) {
    final newRut = Rut.dirty(value);
    state = state.copyWith(
      rut: newRut,
      isValid: Formz.validate([ newRut, state.rut ])
    );
  }
  
  onBirthayChange( String value ) {
    final newBirthday = Birthday.dirty(value);
    state = state.copyWith(
      birthday: newBirthday,
      isValid: Formz.validate([ newBirthday, state.birthday ])
    );
  }

  onEmailChange( String value ) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: Formz.validate([ newEmail, state.email ])
    );
  }

  onPhoneChange( String value ) {
    final newPhone = Phone.dirty(value);
    state = state.copyWith(
      phone: newPhone,
      isValid: Formz.validate([ newPhone, state.phone ])
    );
  }

  onPasswordChanged( String value ) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
      password: newPassword,
      isValid: Formz.validate([ newPassword, state.password ])
    );
  }

  Future<bool> onFormSubmit() async {

    try {
      
      _touchEveryField();

      if ( !state.isValid ) return false;

      state = state.copyWith(isPosting: true);

      await registerUserCallback( 
        state.email.value, 
        state.password.value, 
        state.name.value, 
        state.rut.value, 
        state.birthday.value, 
        state.phone.value
      );

      state = state.copyWith(isPosting: false);

      return true;

    } catch (e) {
      e.toString();
      return false;
    }
  }

  _touchEveryField() {

    final name     = Name.dirty(state.name.value);
    final rut      = Rut.dirty(state.rut.value);
    final birthday = Birthday.dirty(state.birthday.value);
    final email    = Email.dirty(state.email.value);
    final phone    = Phone.dirty(state.phone.value);
    final password = Password.dirty(state.password.value);

    state = state.copyWith(
      isFormPosted: true,
      name: name,
      rut: rut,
      birthday: birthday,
      email: email,
      phone: phone,
      password: password,
      isValid: Formz.validate([ 
        name, 
        rut, 
        birthday, 
        email, 
        phone, 
        password 
      ])
    );

  }

}

class RegisterFormState {

  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Name name;
  final Rut rut;
  final Birthday birthday;
  final Email email;
  final Phone phone;
  final Password password;

  RegisterFormState({
    this.isPosting      = false,
    this.isFormPosted   = false,
    this.isValid        = false,
    this.name           = const Name.pure(),
    this.rut            = const Rut.pure(),
    this.birthday       = const Birthday.pure(),
    this.email          = const Email.pure(),
    this.phone          = const Phone.pure(),
    this.password       = const Password.pure()
  });

  RegisterFormState copyWith({
    bool?       isPosting,
    bool?       isFormPosted,
    bool?       isValid,
    Name?       name,
    Rut?        rut,
    Birthday?   birthday,
    Email?      email,
    Phone?      phone,
    Password?   password,
  }) => RegisterFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    name: name ?? this.name,
    rut: rut ?? this.rut,
    birthday: birthday ?? this.birthday,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    password: password ?? this.password,
  );

  @override
  String toString() {
    return '''
      RegisterFormState:
        isPosting: $isPosting
        isFormPosted: $isFormPosted
        isValid: $isValid
        name: $name
        rut: $rut
        birthday: $birthday
        email: $email
        phone: $phone
        password: $password
    ''';
  }
}
