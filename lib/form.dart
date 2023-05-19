import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Emergencia';
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Center(
              child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
          )),
        ),
        body: const MyCustomForm(),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            const TextField(),
            const TextField(),
            const TextField(),
            const TextField(),
            ElevatedButton(
              onPressed: () {},
              child: const Text(
                'Solicitar',
                style: TextStyle(fontSize: 32.0),
              ),
            )
          ],
        ));
  }
}
