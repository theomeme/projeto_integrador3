import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:projeto_integrador3/database/FirebaseHelper.dart';
import 'package:projeto_integrador3/src/emergency/emergency_model.dart';

class EmergencyConfirmation extends StatefulWidget {
  final String professionalUid;
  final String responseId;

  const EmergencyConfirmation({
    required this.professionalUid,
    required this.responseId,
    super.key,
  });

  @override
  _EmergencyConfirmationState createState() => _EmergencyConfirmationState();
}

class _EmergencyConfirmationState extends State<EmergencyConfirmation> {
  final int endTime = DateTime.now().millisecondsSinceEpoch +
      20000; // Define o tempo inicial do temporizador (1 minuto)

  Stream<DocumentSnapshot> getEmergencySnapshot() async* {
    String? emergencyId = await Emergency.getEmergencyId();

    if (emergencyId != null) {
      yield* FirebaseHelper.getFirestore()
          .collection("emergencies")
          .doc(emergencyId)
          .snapshots();
    }
  }

  Stream<DocumentSnapshot> getResponseSnapshot() async* {
    yield* FirebaseHelper.getFirestore()
        .collection("responses")
        .doc(widget.responseId)
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        title: const Text(
          'Confirmação',
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: StreamBuilder(
          stream: getEmergencySnapshot(),
          builder: (context, snapshot) {
            DocumentSnapshot? emergency = snapshot.data;

            if (emergency?["status"] == "waiting") {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "Aguarde o dentista entrar em contato",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                        "Não se preocupe, o dentista vai entrar em contato com voce por telefone dentro de 1 minuto."),
                  ),
                  CountdownTimer(
                    endTime: endTime,
                    textStyle: const TextStyle(fontSize: 32),
                    onEnd: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const SplashPage()),
                      // );
                    },
                  ),
                ],
              );
            } else if (emergency?["status"] == "onGoing") {
              return StreamBuilder(
                stream: getResponseSnapshot(),
                builder: (context, snapshot) {
                  var response = snapshot.data;

                  if (response?.get("willProfessionalMove") == 0) {
                    print("not moving");
                  } else if (response?.get("willProfessionalMove") == 1) {
                    print("moving");
                  } else {
                    print("xabu");
                  }

                  return Container();
                },
              );
            } else {
              print('xabu status');
              return Container();
            }
          },
        ),
      ),
    );
  }
}
