import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:projeto_integrador3/src/authentication.dart';

class EmergencyViewModel {
  final CollectionReference emergencies =
      FirebaseFirestore.instance.collection('emergencies');
  final storageRef = FirebaseStorage.instance.ref();

  Future<Object?> checkOngoingEmergency() async {
    final auth = Authentication();
    try {
      final userData = await auth.retrieveLocalInfo();
      final ongoingEmergency = await FirebaseFirestore.instance
          .collection('emergencies')
          .where('rescuerUid', isEqualTo: userData['rescuerUid'])
          .where('status', isEqualTo: 'onGoing')
          .get()
          .catchError((e) => e);
      return ongoingEmergency;
    } catch (e) {
      print(e);
      return e;
    }
  }

  Future<DocumentReference> createEmergencyDraft(
      String name, String phone) async {
    final auth = Authentication();

    final userData = await auth.retrieveLocalInfo();

    final emergency = await emergencies.add({
      'rescuerUid': userData['rescuerUid'],
      'name': name,
      'phoneNumber': phone,
      'status': 'drafting',
      'photos': [],
      'location': [],
      'createdAt': DateTime.now(),
    });

    return emergency;
  }

  Future<void> uploadImages(List<String> imagesPath, DocumentReference docRef,
      ValueSetter uploadProgress, ValueSetter uploadLabel) async {
    final List<String> imagesName = [
      'accident',
      'document',
      'accidentDocument'
    ];

    final List<String> fileImagesName = List<String>.generate(
      3,
      (index) =>
          '${docRef.id}_${DateTime.now().millisecondsSinceEpoch}_${imagesName[index]}',
    );

    List<Reference> references = List<Reference>.generate(
        3,
        (index) =>
            storageRef.child('emergencies/images/${fileImagesName[index]}'));

    final uploadTask = references
        .map((ref) => ref.putFile(File(imagesPath[references.indexOf(ref)])))
        .toList();

    List<String> emergencyImageDownloadUrl = [];

    for (var task in uploadTask) {
      task.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
        switch (taskSnapshot.state) {
          case TaskState.running:
            print(taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            uploadProgress(
                taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            break;
          case TaskState.paused:
            print("Upload is paused.");
            break;
          case TaskState.canceled:
            print("Upload was canceled");
            break;
          case TaskState.error:
            // Handle unsuccessful uploads
            break;
          case TaskState.success:
            break;
        }
      });
      task.whenComplete(
        () async => await task.snapshot.ref.getDownloadURL().then(
          (value) {
            emergencyImageDownloadUrl.add(value);
            if (emergencyImageDownloadUrl.length == 3) {
              addImagesToEmergency(emergencyImageDownloadUrl, docRef);
            }
          },
        ),
      );
    }
  }

  Future<void> addImagesToEmergency(
    List<String> images,
    DocumentReference emergencyRef,
  ) async {
    print('docref: ${emergencyRef.id}, images: $images');
    return FirebaseFirestore.instance.collection('emergencies').doc(emergencyRef.id).update({
      'photos': FieldValue.arrayUnion(images),
      'status': 'waiting',
    });
  }
}
