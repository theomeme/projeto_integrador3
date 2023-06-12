import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Emergency {
  static Future<QuerySnapshot> getEmergencyDoc() =>
      FirebaseFirestore.instance.collection("emergencies").get();

  static void saveEmergencyId(String emergencyId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('emergencyId', emergencyId);
  }

  static Future<String?> getEmergencyId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final emergencyId = prefs.getString('emergencyId');
      return emergencyId;
    } catch (e){
      return '';
    }
  }

  static Future<void> wipeEmergencyData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('emergencyId');
  }
}
