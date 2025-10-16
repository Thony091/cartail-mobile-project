// ignore_for_file: avoid_print, unused_local_variable


import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/domain.dart';

class FirestoreService extends FirestoreServiceRepository {  

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future addDataToFirestore(
    Map<String, dynamic> data, 
    String collectionName, 
    String docName) 
  async {
    try {
      
      // Add data to Firestore
      await _firestore.collection(collectionName).doc(docName).set(data);

    } catch (e) {
      print(e);
      throw Exception(e.toString());
    }
  }

  @override
  Future updateDataToFirestore(Map<String, dynamic> data, String collectionName, String docName) async {
    try {

      await _firestore
      .collection(collectionName)
      .doc(docName)
      .update(data)
      .then((value) => print('Data updated'))
      .catchError((error) => print('Failed to update data: $error'));

    } catch (e) {
      print(e);
      throw Exception(e.toString());
    }
  }
  
  @override
  Future<Map<String,dynamic>> getUserDataFromFirestore(String collectionName, String docName) async {
    try {
      final userData = await _firestore.collection(collectionName).doc(docName).get();

      if (userData.data() == null) {
        throw Exception('No data found');
      }

      return userData.data() as Map<String, dynamic>;
    } catch (e) {
      print(e);
      throw Exception(e.toString());
    }
  }
  
  @override
  Future resetPasswordByEmail(String email) {
    // TODO: implement resetPasswordByEmail
    throw UnimplementedError();
  }
}
