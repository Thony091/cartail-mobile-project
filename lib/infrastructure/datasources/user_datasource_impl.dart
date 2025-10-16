// import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../config/config.dart';
import '../../domain/domain.dart';
import '../infrastructure.dart';

class UserDatasourceImpl extends UserDatasource {

  // final dio = Dio( BaseOptions(
  //   baseUrl: "${Enviroment.baseUrl}/user-rest"
  // ));
  
  @override
  Future<User> checkAuthStatus(String token) {
    throw UnimplementedError();
  }
  
  @override
  Future<void> deleteUser() {
    throw UnimplementedError();
  }
  
  @override
  Future<User> getUser(String collectionName, String uid) async {

    try {
      final data = await FirestoreService().getUserDataFromFirestore('users', uid);
      final userDataFirestore = UserFirestoreResponse.fromJson(data);
      final userData = UserMapper.userDbToEntity(userDataFirestore);
      return userData;
    } catch (e) {
      throw CustomError("Errrrror getUser(): ${e.toString()}");
    }

  }
  
  @override
  Future<bool> register(
    String email, String password, String name, String rut, String birthday, String phone, String uid) async {

    try {  
      final user = await FirebaseAuthService.auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      final data = {
        'email': email,
        'password': password,
        'uid': user.user!.uid,
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'rut': rut,
        'birthday': birthday,
        'phone': phone,
        'bio': '',
        'ProfileImage': '',
        'isAdmin': false,
      };
      await FirestoreService().addDataToFirestore(data, 'users', user.user!.uid);
      return true;
    } catch (e) {
      throw CustomError("Errrrror: ${e.toString()}");
    }
  }
  
  @override
  Future<User> updateUser( Map<String, dynamic> userSimilar, String uid ) async {
    
    try {
      await FirestoreService().updateDataToFirestore( userSimilar, 'users', uid);
      final newUserData = await getUser('users', uid);
      return newUserData;
    } catch (e) {
      throw Exception(e);
    }

  }
  
  @override
  Future<firebase_auth.UserCredential> login(String email, String password) async {

    try {
      final user = await FirebaseAuthService.auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return user;
    } catch (e) {
      throw CustomError("Errrrror: ${e.toString()}");
    }

  }
  
  @override
  Future<void> resetPasswordByEmail(String email) async {
    try {
      await FirebaseAuthService.auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw CustomError("Errrrror: ${e.toString()}");
    }
  }

}