import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseHelper {
  static FirebaseAuth getAuth() => FirebaseAuth.instance;

  static FirebaseMessaging getFCM() => FirebaseMessaging.instance;

  static FirebaseFirestore getFirestore() => FirebaseFirestore.instance;

  static FirebaseStorage getStorage() => FirebaseStorage.instance;

  static FirebaseFunctions getFunctions() => FirebaseFunctions.instance;
}
