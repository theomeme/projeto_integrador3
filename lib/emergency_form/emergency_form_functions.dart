import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EmergencyFormFunctions {
  final CollectionReference emergencies =
  FirebaseFirestore.instance.collection('emergencies');
  final storageRef = FirebaseStorage.instance.ref();

  Future<DocumentReference<Object?>> createEmergency(String name, String phone) {
    return emergencies.add({
      'name': name,
      'phoneNumber': phone,
      'status': 'drafting',
      'photos': [],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Future<void> uploadImages(List<String> imagesPath, Future<DocumentReference<Object?>> docRef) async {
  //   final List<String> imagesName = [
  //     'accident',
  //     'document',
  //     'accidentDocument'
  //   ];
  //   final List<String> fileImagesName = List<String>.generate(
  //       3,
  //           (index) =>
  //       '${docRef.id}_${DateTime
  //           .now()
  //           .millisecondsSinceEpoch}_${imagesName[index]}');
  //
  //   List<Reference> references = List<Reference>.generate(
  //       3,
  //           (index) =>
  //           storageRef.child('emergencies/images/${fileImagesName[index]}'));
  //
  //   final uploadTask = references
  //       .map((ref) => ref.putFile(File(imagesPath[references.indexOf(ref)])));
  // }
}
