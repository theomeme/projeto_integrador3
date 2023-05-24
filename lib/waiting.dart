import 'package:flutter/material.dart';
import 'package:projeto_integrador3/andamento.dart';
import 'package:projeto_integrador3/old_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ProgressIndicatorExample(),
    );
  }
}

class ProgressIndicatorExample extends StatefulWidget {
  const ProgressIndicatorExample({super.key});

  @override
  State<ProgressIndicatorExample> createState() =>
      _ProgressIndicatorExampleState();
}

class _ProgressIndicatorExampleState extends State<ProgressIndicatorExample>
    with TickerProviderStateMixin {
  late AnimationController controller;
  bool determinate = false;
  CollectionReference responses =
      FirebaseFirestore.instance.collection('responses');
  final Stream<QuerySnapshot> _responsesStream = FirebaseFirestore.instance
      .collection('responses')
      .where('status', isEqualTo: 'ACEITADO')
      .limit(5)
      .snapshots();

  @override
  void initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SecondPage()),
            );
          },
        ),
        backgroundColor: Colors.redAccent,
        title: const Text('Emergencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const Text(
              'Estamos procurando profissionais para te ajudar...',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 30),
            CircularProgressIndicator(
              backgroundColor: Colors.grey,
              color: Colors.redAccent,
              value: controller.value,
              semanticsLabel: 'Circular progress indicator',
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _responsesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Alguma coisa deu errado');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Carregando informações');
                }

                var docs = snapshot.data!.docs;

                return Expanded(
                  child: ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(docs[index]['professional']),
                          subtitle: const Text(
                            'Dentista achado!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          leading: const Icon(Icons.person),
                          trailing: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Andamento()));
                              }),
                        );
                      }),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
