import 'package:flutter/material.dart';
import 'package:projeto_integrador3/form.dart';
import 'package:projeto_integrador3/main.dart';

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
          mainAxisAlignment: MainAxisAlignment.center,
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
            // Row(
            //   children: <Widget>[
            //     const Expanded(
            //       child: Text(
            //         'Parar de procurar',
            //         style: TextStyle(fontWeight: FontWeight.bold),
            //       ),
            //     ),
            //     Switch(
            //       value: determinate,
            //       onChanged: (bool value) {
            //         setState(
            //           () {
            //             determinate = value;
            //             if (determinate) {
            //               controller.stop();
            //             } else {
            //               controller
            //                 ..forward(from: controller.value)
            //                 ..repeat();
            //             }
            //           },
            //         );
            //       },
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
