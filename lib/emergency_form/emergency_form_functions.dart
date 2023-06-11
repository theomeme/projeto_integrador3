import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EmergencyFormFunctions {
  final CollectionReference emergencies =
      FirebaseFirestore.instance.collection('emergencies');
  final storageRef = FirebaseStorage.instance.ref();

  Future<DocumentReference<Object?>> createEmergency(
      String name, String phone) {
    return emergencies.add({
      'name': name,
      'phoneNumber': phone,
      'status': 'drafting',
      'photos': [],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }


}
