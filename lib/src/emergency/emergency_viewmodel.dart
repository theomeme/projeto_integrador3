import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projeto_integrador3/src/authentication.dart';
import 'package:projeto_integrador3/src/emergency/emergency_model.dart';

class EmergencyViewModel {
  final CollectionReference emergencies =
      FirebaseFirestore.instance.collection('emergencies');
  final storageRef = FirebaseStorage.instance.ref();

  Future<Object?> checkOngoingEmergency() async {
    try {
      final userData = await Authentication.getLocalInfo();
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

  Future<DocumentSnapshot<Object?>> createEmergency(
    String name,
    String phone,
    Position location,
  ) async {
    final userData = await Authentication.getLocalInfo();

    await emergencies.doc(userData['rescuerUid']).set({
      'rescuerUid': userData['rescuerUid'],
      'name': name,
      'phoneNumber': phone,
      'status': 'waiting',
      'photos': [],
      'location':
          FieldValue.arrayUnion([location.latitude, location.longitude]),
      'createdAt': DateTime.now(),
    });

    final emergency = await emergencies.doc(userData['rescuerUid']).get();

    Emergency.saveEmergencyId(emergency.id);

    return emergency;
  }

  Future<void> makeEmergency(
    List<String> imagesPath,
    String name,
    String phoneNumber,
    Position location,
    ValueSetter uploadProgress,
    ValueSetter uploadLabel,
    VoidCallback goToList,
  ) async {
    final rescuerInfo = await Authentication.getLocalInfo();

    final List<String> imagesName = [
      'accident',
      'document',
      'accidentDocument'
    ];

    print(imagesPath);

    for (var image in imagesPath) {
      String temporaryPath = "/data/user/0/com.example.projeto_integrador3/cache/tmpPathCompressedImage.jpg";

      await FlutterImageCompress.compressAndGetFile(image, temporaryPath, quality: 60).then((value) => image = temporaryPath);
    }

    final List<String> fileImagesName = List<String>.generate(
        3,
        (index) =>
            '${rescuerInfo["rescuerUid"]}_${DateTime.now().millisecondsSinceEpoch}_${imagesName[index]}');

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
        () async => await task.snapshot.ref.getDownloadURL().then((value) {
          emergencyImageDownloadUrl.add(value);
          if (emergencyImageDownloadUrl.length == 3) {
            createEmergency(name, phoneNumber, location).then(
              (value) {
                addImagesToEmergency(emergencyImageDownloadUrl, value.id);
                goToList();
              },
            );
          }
        }),
      );
    }
  }

  Future<void> addImagesToEmergency(
    List<String> images,
    String emergencyId,
  ) async {
    return FirebaseFirestore.instance
        .collection('emergencies')
        .doc(emergencyId)
        .update({
      'photos': FieldValue.arrayUnion(images),
    });
  }

  Future<Position> getPosition(context) async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    bool locationEnabled = await Geolocator.isLocationServiceEnabled();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Você precisa autorizar o acesso à localização para abrir um chamado.'),
          ),
        );
        return Future.error('Você precisa autorizar o acesso à localização');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Você precisa autorizar o acesso à localização para abrir um chamado.'),
          action: SnackBarAction(
            label: "Abrir configurações",
            onPressed: () {
              Geolocator.openAppSettings();
            },
          ),
        ),
      );
      return Future.error('Você precisa autorizar o acesso à localização');
    }

    if (!locationEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ative a localização para prosseguir.'),
        ),
      );
      return Future.error('Por favor, habilite a localização no smartphone');
    }

    return await Geolocator.getCurrentPosition();
  }
}
