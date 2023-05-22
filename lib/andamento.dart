import 'package:flutter/material.dart';

class Andamento extends StatelessWidget {
  const Andamento({super.key});

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
        body: const Text(
          'Chamado em andamento!',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
