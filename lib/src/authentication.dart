import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Authentication{
  Future<void> getAuth() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final fcmToken = await FirebaseMessaging.instance.getToken();
      await preferences.setString('rescuerUid', userCredential.user!.uid);
      await preferences.setString('fcmToken', fcmToken!);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error.");
      }
    }
  }

  Future<List<String>> findUserInfo() async {
    try {
      final SharedPreferences preferences = await SharedPreferences.getInstance();

      final rescuerUid = preferences.getString('rescuerUid');
      final fcmToken = preferences.getString('fcmToken');

      final List<String> userInfo = [rescuerUid!, fcmToken!];

      return userInfo;

    } catch (e) {
      await getAuth();
      return await findUserInfo();
    }
  }


  Future<List> checkLocalInfo() async {
    try {
      final SharedPreferences preferences = await SharedPreferences.getInstance();

      final rescuerUid = preferences.getString('rescuerUid');
      final fcmToken = preferences.getString('fcmToken');

      final List<String> userInfo = [rescuerUid!, fcmToken!];

      return userInfo;
    } catch (e) {
      throw ErrorDescription('No information found.');
    }
  }
}