import 'package:flutter/material.dart';
import 'package:projeto_integrador3/form.dart';
import 'package:projeto_integrador3/waiting.dart';

void main() {
  runApp(const ProgressIndicatorApp());
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
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SecondPage()),
                    );
                  },
                  icon: const Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: 36,
                  ),
                ),
              ],
            ),
            const Text(
              'Pedir socorro!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            )
          ],
        ),
      ),
    );
  }
}
