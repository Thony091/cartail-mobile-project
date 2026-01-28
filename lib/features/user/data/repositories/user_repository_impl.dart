import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required UserDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final UserDatasource _remoteDatasource;

  @override
  Future<User> checkAuthStatus(String token) {
    return _remoteDatasource.checkAuthStatus(token);
  }

  @override
  Future<void> deleteUser() async {
    await _remoteDatasource.deleteUser();
  }

  @override
  Future<User> getUser(String collectionName, String uid) {
    return _remoteDatasource.getUser(collectionName, uid);
  }

  @override
  Future<firebase_auth.UserCredential> login(String email, String password) {
    return _remoteDatasource.login(email, password);
  }

  @override
  Future<bool> register(
    String email,
    String password,
    String name,
    String rut,
    String birthday,
    String phone,
    String uid,
  ) {
    return _remoteDatasource.register(email, password, name, rut, birthday, phone, uid);
  }

  @override
  Future<User> updateUser(Map<String, dynamic> userSimilar, String uid) {
    return _remoteDatasource.updateUser(userSimilar, uid);
  }

  @override
  Future<void> resetPasswordByEmail(String email) {
    return _remoteDatasource.resetPasswordByEmail(email);
  }

}
