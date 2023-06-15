import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  // static Future<bool> checkForOngoingEmergency() async {}

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

        getResponseAndProfessionalUid(rescuerUid: id!).then(
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
}
