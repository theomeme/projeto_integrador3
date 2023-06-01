import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projeto_integrador3/firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EmergencyFormFunctions {

  final CollectionReference emergencies = FirebaseFirestore.instance.collection('emergencies');


  Future<DocumentReference<Object?>> createEmergency(String name, String phone) {
    return emergencies.add({
      'name': name,
      'phoneNumber': phone,
      'status': 'drafting',
      'photos': [],
      'createdAt': DateTime.now(),
    });
  }
}