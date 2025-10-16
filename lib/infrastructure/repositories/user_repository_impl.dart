

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/domain.dart';
import '../infrastructure.dart';

class UserRepositoryImpl implements UserRepository {

  final UserDatasource datasource;

  UserRepositoryImpl( {
    UserDatasource? datasource
  }) : datasource = datasource ?? UserDatasourceImpl();
  

  @override
  Future<User> checkAuthStatus(String token) async {
    return await datasource.checkAuthStatus(token);
  }

  @override
  Future<void> deleteUser() async {
    return await datasource.deleteUser();
  }

  @override
  Future<User> getUser(String collectionName, String uid) async {
    return await datasource.getUser( collectionName, uid);
  }

  @override
  Future<firebase_auth.UserCredential> login(String email, String password) async {
    return await datasource.login(email, password);
  }

  @override
  Future<bool> register(String email, String password, String name, String rut, String birthday, String phone, String uid) async {
    return await datasource.register(email, password, name, rut, birthday, phone, uid);
  }

  @override
  Future<User> updateUser(Map<String, dynamic> userSimilar, String uid) async {
    return await datasource.updateUser(userSimilar, uid);
  }
  
  @override
  Future<void> resetPasswordByEmail(String email) {
    return datasource.resetPasswordByEmail(email);
  }
}