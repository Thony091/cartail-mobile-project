import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../domain.dart';

abstract class UserRepository {

  Future<User> getUser(String collectionName, String uid);
  
  Future<firebase_auth.UserCredential> login (String email, String password);

  Future<bool> register(String email, String password, String name, String rut, String birthday, String phone, String uid);

  Future<User> updateUser( Map<String, dynamic> userSimilar, String uid);

  Future<void> deleteUser();

  Future<User> checkAuthStatus(String token);

  Future<void> resetPasswordByEmail(String email);
  
}