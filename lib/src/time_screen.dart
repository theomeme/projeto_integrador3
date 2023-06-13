import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:projeto_integrador3/src/splash/splash_page.dart';

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final int endTime = DateTime.now().millisecondsSinceEpoch +
      20000; // Define o tempo inicial do temporizador (1 minuto)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        title: const Text(
          'Emergência',
        ),
      ),
      body: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Contato com o Destista",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              const Text(
                "Aguarde o dentista entrar em contato",
                style: TextStyle(fontSize: 16),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    "Nao se preocupe, o dentista vai entrar em contato com voce por telefone."),
              ),
              CountdownTimer(
                endTime: endTime,
                textStyle: const TextStyle(fontSize: 32),
                onEnd: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SplashPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
