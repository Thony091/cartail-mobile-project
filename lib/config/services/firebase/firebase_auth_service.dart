import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {

  static late FirebaseAuth auth;

  static void init(){
    auth = FirebaseAuth.instance;
  }

  static Future<void> logOut() async {
    await auth.signOut();
  }

  static Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      print('Error de autentificación: $e');
      return null;
    }
  } 

  static Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // userCredential
      return userCredential;
    } catch (e) {
      print('Error en el registro: $e');
      return null;
    }
  }

  static Future<void> resetPasswordByEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error en el envio de correo: $e');
    }
  }

}