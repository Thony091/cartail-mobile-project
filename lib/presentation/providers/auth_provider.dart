import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:portafolio_project/config/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';
import '../../infrastructure/infrastructure.dart';
import '../shared/shared.dart';

/// Proveedor de estado para la gestión de la autenticación.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  
  final authRepository = UserRepositoryImpl(); 
  final keyValueStorageService = KeyValueStorageServiceImpl();
  
  return AuthNotifier(
    authRepository: authRepository,
    keyValueStorageService: keyValueStorageService
  );
});

/// Clase notificadora de estado para la gestión de la autenticación.
class AuthNotifier extends StateNotifier<AuthState>{
  
  final UserRepository authRepository;
  final KeyValueStorageService keyValueStorageService;

  AuthNotifier({
    required this.authRepository,
    required this.keyValueStorageService,
  }): super(AuthState()){
    checkAuthStatus();
  }

  /// Método para verificar el estado de autenticación.
  void checkAuthStatus() async {
    
    final token = await keyValueStorageService.getValue<String>('token');
    final email = await keyValueStorageService.getValue<String>('email');
    final password = await keyValueStorageService.getValue<String>('password');
    
    if( token == null ) return logOut();

    try {

      await loginUserFireBase(email.toString(), password.toString());
      
    } catch (e) {
      logOut();
    }

  }

  /// Método para iniciar sesión de un usuario.
  Future<void> loginUserFireBase( String email, String password ) async {

    await Future.delayed(const Duration(milliseconds: 500));

    try {

      final user = await FirebaseAuthService.auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      final userData = await authRepository.getUser('users', user.user!.uid);

      // await keyValueStorageService.setKeyValue('uid',  user.user!.uid);
      await keyValueStorageService.setKeyValue('email', userData.email);
      await keyValueStorageService.setKeyValue('password', userData.password);

      _setLoggedUser(user, userData);

    } on CustomError {
      logOut( 'Credenciales no son correctas' );
    } catch(e){
      logOut('Error no controlado');
    }
    print('Status desde logIn(): ${state.authStatus}');
  }

  /// Método para registrar un nuevo usuario.
  Future<bool> registerUserFireBase( 
    String email, String password, String name, String rut, String birthday, String phone ) async {

    try {
      
      await authRepository.register(email, password, name, rut, birthday, phone, '');
      print('Usuario registrado correctamente');
      return true;

    } catch (e) {
      logOut(e.toString());
      return false;
    }
    
  }

  Future<bool> addUserToDatabase ( Map<String, dynamic> data, String collectionName, String docName ) async {
    
    bool value = false;

    try {
      await FirestoreService().addDataToFirestore(data, collectionName, docName);
      value = true;
    } catch (e) {
      logOut(e.toString());
      print(e);
      value = false;
    }
    return value;
  }

  Future<bool> updateDataToFirestore ( Map<String, dynamic> userSimilar ) async {

    // final userData = await keyValueStorageService.getValue('userData');

    try {
      final user = await FirebaseAuthService.auth.signInWithEmailAndPassword(
        email: state.userData!.email, 
        password: state.userData!.password
      );
      
      final userData = await authRepository.updateUser( userSimilar, user.user!.uid );

      state = state.copyWith(
        userData: userData
      );

      return true;
    } catch (e) {
      Exception("Error en actualizacion: ${e.toString()}");
      print(e);
      return false;
    }

  }

  /// Método privado para establecer el usuario autenticado. 
  void _setLoggedUser (firebase_auth.UserCredential user, User userData) async {

    final tokenId = await user.user!.getIdToken();
 
    // Verifica si tokenId es null antes de intentar almacenarlo.
    if ( tokenId != null ) {

      await keyValueStorageService.setKeyValue('token', tokenId);

    } else {
      print('Token ID is null');
    }
    
    final token = await keyValueStorageService.getValue<String>('token');
    print('Token guardado?: $token');

    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: '',
      userData: userData,
      token: tokenId,
    );
    
    // if (state.userData != null) {

    //   await keyValueStorageService.setKeyValue('userData', state.userData);

    // }

  }

  Future<void> resetPasswordByEmail( String email ) async {
    try {
      await authRepository.resetPasswordByEmail(email);
    } catch (e) {
      logOut(e.toString());
    }
  }

  /// Método para actualizar el usuario.
  Future<void> updateUser( Map<String, dynamic> userSimilar,  ) async {

    final userData = await keyValueStorageService.getValue('userData');
    try {
      final user = await authRepository.updateUser(userSimilar, userData );

      state = state.copyWith(
        userData: user
      );
      
    } catch (e) {
      Exception("Error en actualizacion: ${e.toString()}");
    }
  }

  /// Método para cerrar sesión del usuario.
  Future<void> logOut([ String? errorMessage ]) async {

    try {
      
      await FirebaseAuthService.logOut();
      
      await keyValueStorageService.removeKey('token');
      await keyValueStorageService.removeKey('email');
      await keyValueStorageService.removeKey('password');
      print('Token eliminado correctamente');
      

      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        user: null,
        errorMessage: errorMessage
      );
      print('Status desde logOut(): ${state.authStatus}');
      
    } catch (e) {
      print(e); 
    }
  }
}

/// Enumeración que representa los posibles estados de autenticación.
enum AuthStatus{ checking, authenticated, notAuthenticated}

/// Clase que representa el estado de la autenticación.
class AuthState {
   
  final AuthStatus authStatus;
  final firebase_auth.UserCredential? user;
  final String errorMessage;
  final User? userData;
  final String token;


  AuthState({
    this.authStatus = AuthStatus.checking, 
    this.user, 
    this.errorMessage = '',
    this.userData,
    this.token = '',
  });

  /// Método para crear una copia del estado con cambios específicos.
  AuthState copyWith({
    AuthStatus? authStatus,
    firebase_auth.UserCredential? user,
    String? errorMessage,
    User? userData,
    String? token,
  }) => AuthState(
    authStatus: authStatus ?? this.authStatus,
    user: user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage,
    userData: userData ?? this.userData,
    token: token ?? this.token
  );

  @override
  String toString() {
    return '''
      AuthState:
      authStatus: $authStatus, 
      user: $user, 
      errorMessage: $errorMessage, 
      userData: $userData
      token: $token
    ''';
  }

  void addListener(Null Function(dynamic state) param0) {}

}