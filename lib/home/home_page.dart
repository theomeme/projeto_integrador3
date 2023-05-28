import 'package:flutter/material.dart';
import 'package:projeto_integrador3/emergency_form/emergency_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        title: const Text(
          'TeethKids',
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Column(
            children: [
              Text(
                'Teve uma emergência?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                'Aperte o botão para solicitar ajuda.',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(
            height: 75,
          ),
          Center(
            child: FloatingActionButton.large(
              backgroundColor: Colors.redAccent,
              splashColor: Colors.white70,
              elevation: 0,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyFormPage(),
                  ),
                );
              },
              child: const Icon(Icons.touch_app),
            ),
          ),
        ],
      ),
    );
  }
}
