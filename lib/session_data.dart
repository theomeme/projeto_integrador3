import 'package:shared_preferences/shared_preferences.dart';

void saveUserUID(String uid) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString('UID', uid);
}

void saveUserFCM(String fcm) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString('FCM', fcm);
}


