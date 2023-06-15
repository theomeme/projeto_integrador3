import 'package:flutter/material.dart';
import 'package:projeto_integrador3/src/authentication.dart';
import 'package:projeto_integrador3/src/emergency/emergency_confirmation.dart';
import 'package:projeto_integrador3/src/emergency/emergency_model.dart';
import 'package:projeto_integrador3/src/home/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final authentication = Authentication();

  @override
  initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () => Emergency.checkForOngoingEmergency(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }, (value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmergencyConfirmation(
              value![0],
              value[1],
              value[2],
            ),
          ),
        );
      }),
    );
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
