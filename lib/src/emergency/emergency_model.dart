import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projeto_integrador3/database/FirebaseHelper.dart';
import 'package:projeto_integrador3/src/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Emergency {
  static Future<DocumentSnapshot> getEmergencyDoc(
          {required emergencyId}) async =>
      await FirebaseHelper.getFirestore()
          .collection("emergencies")
          .doc(emergencyId)
          .get();

  static void saveEmergencyId(String emergencyId) async =>
      await SharedPreferences.getInstance()
          .then((prefs) => prefs.setString('emergencyId', emergencyId));

  static Future<String?> getEmergencyId() async =>
      await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('emergencyId'));

  static Future<void> wipeEmergencyData() async =>
      await SharedPreferences.getInstance()
          .then((prefs) => prefs.remove('emergencyId'));

  static void checkForOngoingEmergency(
      VoidCallback navigateToHome, ValueSetter<List?> goToOngoingEmergency) {
    if (!Authentication.isAuthenticated()) {
      Authentication.setAuth();
      Authentication.setFCM();
      return navigateToHome();
    }

    getEmergencyId().then((id) {
      if (id == null) {
        Authentication.wipeLocalInfo();
        Authentication.setAuth();
        Authentication.setFCM();
        return navigateToHome();
      }

      getEmergencyDoc(emergencyId: id).then((doc) async {
        if (doc.get("status") != "onGoing") {
          Authentication.wipeLocalInfo();
          wipeEmergencyData();
          Authentication.setAuth();
          Authentication.setFCM();
          return navigateToHome();
        }

        getResponseAndProfessionalUid(rescuerUid: id).then(
          (value) => goToOngoingEmergency([
            value.docs.first.get("professionalUid"),
            value.docs.first.id,
            id,
          ]),
        );
      });
    });
  }

  static Future<QuerySnapshot> getResponseAndProfessionalUid({
    required String rescuerUid,
  }) async =>
      await FirebaseHelper.getFirestore()
          .collection("responses")
          .where("rescuerUid", isEqualTo: rescuerUid)
          .where("status", isEqualTo: "onGoing")
          .get();

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
      return e;
    }
  }

  Future<DocumentSnapshot<Object?>> createEmergency(
    String name,
    String phone,
    Position location,
  ) async {
    final userData = await Authentication.getLocalInfo();

    await FirebaseHelper.getFirestore()
        .collection("emergencies")
        .doc(userData['rescuerUid'])
        .set({
      'rescuerUid': userData['rescuerUid'],
      'name': name,
      'phoneNumber': phone,
      'status': 'waiting',
      'photos': [],
      'location':
          FieldValue.arrayUnion([location.latitude, location.longitude]),
      'createdAt': DateTime.now(),
    });

    final emergency = await FirebaseHelper.getFirestore()
        .collection("emergencies")
        .doc(userData['rescuerUid'])
        .get();

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

    for (var image in imagesPath) {
      String temporaryPath =
          "/data/user/0/com.example.projeto_integrador3/cache/tmpPathCompressedImage.jpg";

      await FlutterImageCompress.compressAndGetFile(image, temporaryPath,
              quality: 60)
          .then((value) => image = temporaryPath);
    }

    final List<String> fileImagesName = List<String>.generate(
        3,
        (index) =>
            '${rescuerInfo["rescuerUid"]}_${DateTime.now().millisecondsSinceEpoch}_${imagesName[index]}');

    List<Reference> references = List<Reference>.generate(
        3,
        (index) => FirebaseHelper.getStorage()
            .ref()
            .child('emergencies/images/${fileImagesName[index]}'));

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
            break;
          case TaskState.canceled:
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

  static Future<Position> getPosition(context) async {
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
