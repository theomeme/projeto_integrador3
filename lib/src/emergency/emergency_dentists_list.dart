import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projeto_integrador3/database/FirebaseHelper.dart';
import 'package:projeto_integrador3/src/authentication.dart';
import 'package:projeto_integrador3/src/emergency/emergency_confirmation.dart';
import 'package:projeto_integrador3/src/emergency/emergency_model.dart';
import 'package:projeto_integrador3/src/responses_model.dart';
import 'package:projeto_integrador3/src/splash/splash_page.dart';

class EmergencyDentistsList extends StatefulWidget {
  const EmergencyDentistsList({Key? key});

  @override
  State<EmergencyDentistsList> createState() => _EmergencyDentistsListState();
}

class _EmergencyDentistsListState extends State<EmergencyDentistsList> {
  Stream<List<DocumentSnapshot>> getAwaitResponseProfiles() async* {
    await Future.delayed(const Duration(seconds: 2));
    String? emergencyId = await Emergency.getEmergencyId();

    if (emergencyId != null) {
      yield* FirebaseFirestore.instance
          .collection('responses')
          .where("status", isEqualTo: "waiting")
          .where("rescuerUid", isEqualTo: emergencyId)
          .snapshots()
          .asyncMap((snapshot) => Future.wait(snapshot.docs.map((doc) =>
          FirebaseFirestore.instance
              .collection('profiles')
              .doc(doc['professionalUid'] as String)
              .get())));
    }
  }

  String? emergencyId;

  @override
  void initState() {
    super.initState();
    Emergency.getEmergencyId().then((value) {
      setState(() {
        emergencyId = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Authentication.wipeLocalInfo();
            Emergency.wipeEmergencyData();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SplashPage()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
        title: const Text("Dentistas disponíveis"),
        backgroundColor: Colors.redAccent,
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
          child: StreamBuilder<List<DocumentSnapshot>>(
            stream: getAwaitResponseProfiles(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Algo deu errado'));
              }

              List<DocumentSnapshot>? profileDocs = snapshot.data;

              if (profileDocs == null || profileDocs.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhum dentista foi encontrado até o momento',
                  ),
                );
              }

              return ListView.builder(
                itemCount: profileDocs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot profileDoc = profileDocs[index];
                  String professionalId = profileDoc.id;
                  String name = profileDoc['name'] as String;
                  double rating = profileDoc['rating'] as double;

                  return Card(
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RatingBar.builder(
                            initialRating: rating,
                            ignoreGestures: true,
                            minRating: 0,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              // Update the rating value
                            },
                          ),
                          FutureBuilder<double>(
                            future: _calculateDistance(professionalId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                double distance = snapshot.data!;
                                return Text(
                                    'Distância: ${distance.toStringAsFixed(1)}km');
                              } else if (snapshot.hasError) {
                                return const Text('Erro ao obter a distância');
                              } else {
                                return const SizedBox();
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        _showConfirmationDialog(name, professionalId);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<double> _calculateDistance(String professionalId) async {
    Position currentPosition = await Geolocator.getCurrentPosition();
    DocumentSnapshot addressSnapshot =
    await FirebaseHelper.getFirestore()
        .collection("profiles")
        .doc(professionalId)
        .collection("addresses")
        .where("primary", isEqualTo: true)
        .get()
        .then((snapshot) => snapshot.docs.first);

    double professionalLat = addressSnapshot['lat'] as double;
    double professionalLng = addressSnapshot['lng'] as double;

    double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        professionalLat,
        professionalLng) /
        1000;

    return distance;
  }

  void _showConfirmationDialog(String name, String professionalUid) {
    double distance = 0.0;

    FirebaseHelper.getFirestore()
        .collection("profiles")
        .doc(professionalUid)
        .collection("addresses")
        .where("primary", isEqualTo: true)
        .get()
        .then(
          (addressProfessional) {
        FirebaseHelper.getFirestore()
            .collection("emergencies")
            .doc(emergencyId!)
            .get()
            .then(
              (emergency) {
            FirebaseHelper.getFirestore()
                .collection("responses")
                .where("rescuerUid", isEqualTo: emergencyId!)
                .where("professionalUid", isEqualTo: professionalUid)
                .limit(1)
                .get()
                .then(
                  (response) {
                setState(() {
                  distance = Geolocator.distanceBetween(
                      addressProfessional.docs.first["lat"],
                      addressProfessional.docs.first["lng"],
                      emergency["location"][0],
                      emergency["location"][1]) /
                      1000;
                });
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Confirmação'),
                      content: Text(
                          'Você tem certeza de que deseja escolher o médico $name? Ele está a uma distância de ${distance.toStringAsFixed(1)}km de você.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.black45),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Responses.rejectProfessional(
                                rescuerUid: emergencyId!,
                                professionalUid: professionalUid);
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Recusar',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Responses.acceptProfessional(
                              emergencyId: emergencyId!,
                              professionalUid: professionalUid,
                            );
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmergencyConfirmation(
                                  professionalUid,
                                  response.docs.first.id,
                                  null,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Aceitar',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}