import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:projeto_integrador3/database/FirebaseHelper.dart';
import 'package:projeto_integrador3/src/emergency/emergency_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../review/review_form.dart';

class EmergencyConfirmation extends StatefulWidget {
  final String? professionalUid;
  final String? responseId;
  final String? emergencyId;

  const EmergencyConfirmation(
    this.professionalUid,
    this.responseId,
    this.emergencyId, {
    Key? key,
  }) : super(key: key);

  @override
  _EmergencyConfirmationState createState() => _EmergencyConfirmationState();
}

class _EmergencyConfirmationState extends State<EmergencyConfirmation> {
  String? professionalUid;
  String? responseId;

  final int endTime = DateTime.now().millisecondsSinceEpoch +
      20000; // Define o tempo inicial do temporizador (1 minuto)

  Future<Map<String, dynamic>> getProfessionalAddress() async {
    final querySnapshot = await FirebaseHelper.getFirestore()
        .collection("profiles")
        .doc(widget.professionalUid ?? professionalUid)
        .collection("addresses")
        .where("primary", isEqualTo: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final snapshot = querySnapshot.docs.first;
      return snapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception("Endereço primário não encontrado para o médico");
    }
  }

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
        .doc(widget.responseId ?? responseId)
        .snapshots();
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
                        "Não se preocupe, o dentista vai entrar em contato com você por telefone dentro de 1 minuto."),
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

                  print(response?.id);

                  if (response?.get("willProfessionalMove") == -1) {
                    return const Text(
                      "Esperando a resposta do médico",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    );
                  } else if (response?.get("willProfessionalMove") == 0) {
                    return FutureBuilder(
                      future: getProfessionalAddress(),
                      builder: (context, addressSnapshot) {
                        if (addressSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (addressSnapshot.hasData) {
                          final Map<String, dynamic> addressData =
                              addressSnapshot.data as Map<String, dynamic>;

                          final String street = addressData["street"] ?? "";
                          final String number = addressData["number"] ?? "";
                          final String city = addressData["city"] ?? "";

                          final String fullAddress = "$street $number, $city";

                          return Column(
                            children: [
                              const Text(
                                "O médico está na clínica",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Endereço: $fullAddress",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  launchMaps(fullAddress);
                                },
                                child: const Text("Ver no Mapa"),
                              ),
                            ],
                          );
                        } else {
                          return const Text("Endereço não encontrado");
                        }
                      },
                    );
                  } else if (response?.get("willProfessionalMove") == 1) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "O médico está a caminho!",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Ele logo estará no local para atendê-lo.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  } else {
                    print("xabu");
                  }

                  return Container();
                },
              );
            } else if (emergency?["status"] == "finished") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewForm(
                    professionalUid: widget.professionalUid ?? professionalUid!,
                    emergencyId: emergency?["rescuerUid"],
                  ),
                ),
              );
            } else {
              print('xabu status');
              return Container();
            }
            return Container();
          },
        ),
      ),
    );
  }

  void launchMaps(String address) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeQueryComponent(address)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o mapa';
    }
  }
}
