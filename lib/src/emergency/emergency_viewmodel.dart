import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projeto_integrador3/src/authentication.dart';
import 'package:projeto_integrador3/src/emergency/emergency_model.dart';

class EmergencyViewModel {
  final CollectionReference emergencies =
      FirebaseFirestore.instance.collection('emergencies');
  final storageRef = FirebaseStorage.instance.ref();

  Future<Object?> checkOngoingEmergency() async {
    try {
      final userData = await Authentication.retrieveLocalInfo();
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

  Future<DocumentSnapshot<Object?>> createEmergencyDraft(
      String name, String phone) async {

    final userData = await Authentication.retrieveLocalInfo();

    final location = await getPosition();

    await emergencies.doc(userData['rescuerUid']).set({
      'rescuerUid': userData['rescuerUid'],
      'name': name,
      'phoneNumber': phone,
      'status': 'drafting',
      'photos': [],
      'location': GeoPoint(location.latitude, location.longitude),
      'createdAt': DateTime.now(),
    });

    final emergency = await emergencies.doc(userData['rescuerUid']).get();

    Emergency.saveEmergencyId(emergency.id);

    return emergency;
  }

  Future<void> uploadImages(List<String> imagesPath, DocumentSnapshot docRef,
      ValueSetter uploadProgress, ValueSetter uploadLabel, VoidCallback goToList) async {
    final List<String> imagesName = [
      'accident',
      'document',
      'accidentDocument'
    ];

    final List<String> fileImagesName = List<String>.generate(
        3,
        (index) =>
            '${docRef.id}_${DateTime.now().millisecondsSinceEpoch}_${imagesName[index]}');

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
              goToList();
            }
          },
        ),
      );
    }
  }

  Future<void> addImagesToEmergency(
    List<String> images,
    DocumentSnapshot emergencyRef,
  ) async {
    return FirebaseFirestore.instance
        .collection('emergencies')
        .doc(emergencyRef.id)
        .update({
      'photos': FieldValue.arrayUnion(images),
      'status': 'waiting',
    });
  }

  Future<Position> getPosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    bool locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      return Future.error('Por favor, habilite a localização no smartphone');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Você precisa autorizar o acesso à localização');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Você precisa autorizar o acesso à localização');
    }

    return await Geolocator.getCurrentPosition();
  }
}
