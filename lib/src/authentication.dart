import 'package:projeto_integrador3/database/FirebaseHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authentication {
  static bool isAuthenticated() => FirebaseHelper.getAuth().currentUser != null;
  static String? getAuthUid() => FirebaseHelper.getAuth().currentUser?.uid;

  Future<void> _saveAuthUid({required String rescuerUid}) async =>
      await SharedPreferences.getInstance()
          .then((prefs) => prefs.setString("rescuerUid", rescuerUid));

  Future<void> _saveFcmToken({required String fcmToken}) async =>
      await SharedPreferences.getInstance()
          .then((prefs) => prefs.setString("fcmToken", fcmToken));

  static Future<void> setAuth() async {
    if (!isAuthenticated()) {
      await FirebaseHelper.getAuth().signInAnonymously().then((credential) =>
          Authentication()._saveAuthUid(rescuerUid: credential.user!.uid));
    }
  }

  static Future<void> setFCM() async => await FirebaseHelper.getFCM()
      .getToken()
      .then((token) => Authentication()._saveFcmToken(fcmToken: token!));

  static Future<void> wipeLocalInfo() async =>
      await SharedPreferences.getInstance().then((prefs) async {
        try {
          await FirebaseHelper.getAuth().currentUser!.delete();
        } catch (e) {

        }
        FirebaseHelper.getAuth().signOut();
        prefs.remove("fcmToken");
        prefs.remove("rescuerUid");
      });

  static Future<Map<String, String>> getLocalInfo() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final rescuerUid = preferences.getString('rescuerUid');
    final fcmToken = preferences.getString('fcmToken');

    final Map<String, String> userInfo = {
      'rescuerUid': rescuerUid!,
      'fcmToken': fcmToken!
    };

    return userInfo;
  }
}
