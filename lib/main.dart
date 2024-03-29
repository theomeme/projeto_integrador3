import 'package:flutter/material.dart';
import 'package:projeto_integrador3/src/service/connectivity_manager.dart';
import 'package:projeto_integrador3/src/splash/splash_page.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ConnectivityManager connectivityManager = ConnectivityManager();

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    ),
  );
}
