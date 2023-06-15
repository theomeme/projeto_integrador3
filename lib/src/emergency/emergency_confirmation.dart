import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:projeto_integrador3/database/FirebaseHelper.dart';
import 'package:projeto_integrador3/src/authentication.dart';
import 'package:projeto_integrador3/src/emergency/emergency_model.dart';
import 'package:projeto_integrador3/src/responses_model.dart';
import 'package:projeto_integrador3/src/splash/splash_page.dart';
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
  final int endTime = DateTime.now().millisecondsSinceEpoch +
      60000; // Define o tempo inicial do temporizador (1 minuto)
  
  late CountdownTimerController controller;

  Future<Map<String, dynamic>> getProfessionalAddress() async {
    final querySnapshot = await FirebaseHelper.getFirestore()
        .collection("profiles")
        .doc(widget.professionalUid)
        .collection("addresses")
        .where("primary", isEqualTo: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final snapshot = querySnapshot.docs.first;
      return snapshot.data();
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
        .doc(widget.responseId)
        .snapshots();
  }
  
  @override
  void initState() {
    controller = CountdownTimerController(endTime: endTime);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        title: const Text(
          "Atendimento",
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.redAccent,
            secondary: Colors.black54,
          ),
        ),
        child: Container(
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                          "Não se preocupe, o dentista vai entrar em contato com você por telefone dentro de 1 minuto."),
                    ),
                    CountdownTimer(
                      textStyle: const TextStyle(fontSize: 32),
                      controller: controller,
                      onEnd: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'O dentista escolhido demorou a responder. Escolha outro dentista.'),
                          ),
                        );
                      },
                    ),
                  ],
                );
              } else if (emergency?["status"] == "onGoing") {
                Responses.cancelOtherResponsesNotChosen();
                controller.disposeTimer();

                return StreamBuilder(
                  stream: getResponseSnapshot(),
                  builder: (context, snapshot) {
                    var response = snapshot.data;

                    if (response?.get("willProfessionalMove") == -1) {
                      return const Center(
                        child: Text(
                          "Estamos esperando o dentista enviar ou solicitar localização",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    } else if (response?.get("willProfessionalMove") == 0) {
                      return FutureBuilder(
                        future: getProfessionalAddress(),
                        builder: (context, addressSnapshot) {
                          if (addressSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (addressSnapshot.hasData) {
                            final Map<String, dynamic> addressData =
                                addressSnapshot.data as Map<String, dynamic>;

                            final String street = addressData["street"] ?? "";
                            final String number = addressData["number"] ?? "";
                            final String city = addressData["city"] ?? "";

                            final String fullAddress = "$street $number, $city";

                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "O dentista está esperando você na clínica",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Endereço: $fullAddress",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      launchMaps(fullAddress);
                                    },
                                    child: const Text("Ver no Mapa"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const Center(
                              child: Text(
                                "Endereço não encontrado",
                              ),
                            );
                          }
                        },
                      );
                    } else if (response?.get("willProfessionalMove") == 1) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "O médico está a caminho!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Ele logo estará no local para atendê-lo.",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    return Container();
                  },
                );
              } else if (emergency?["status"] == "finished") {
                goToReview(emergency!.id);
              } else {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Carregando informações"),
                  ],
                );
              }
              return Container();
            },
          ),
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

  void goToReview(String emergency) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewForm(
          professionalUid: widget.professionalUid!,
          emergencyId: emergency,
        ),
      ),
    );
  }
}
