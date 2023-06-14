import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_integrador3/database/FirebaseHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Emergency {
  static Future<QuerySnapshot> getEmergencyDoc() async =>
      await FirebaseHelper.getFirestore().collection("emergencies").get();

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
}
