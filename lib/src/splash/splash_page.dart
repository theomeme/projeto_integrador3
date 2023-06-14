import 'package:flutter/material.dart';
import 'package:projeto_integrador3/src/emergency/emergency_model.dart';
import 'package:projeto_integrador3/src/home/home_page.dart';
import 'package:projeto_integrador3/src/authentication.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final authentication = Authentication();

  @override
  initState() {
    //ele tem que checar por uma emergencia ongoing e redirecionar para tela
    // Emergency.getEmergencyId().then((value) => print(value));
    super.initState();
    Emergency.wipeEmergencyData();
    // await authentication.getAuth();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage('images/logo_app.png'),
        ),
      ),
    );
  }
}
