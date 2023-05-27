import 'package:flutter/material.dart';
import 'package:projeto_integrador3/emergency_form_page.dart';
import 'package:projeto_integrador3/home/home_page.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const MaterialApp(
      home: HomePage(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.redAccent,
            title: const Center(
              child: Text(
                'TeethKids',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
              ),
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => const NewFormPage()),
                      // );
                    },
                    child: const Text(
                      'SOLICITAR\nEMERGENCIA',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Colors.red),
                    ),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
