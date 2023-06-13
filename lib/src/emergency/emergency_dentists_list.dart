import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_integrador3/src/authentication.dart';
import 'package:projeto_integrador3/src/emergency/emergency_model.dart';
import 'package:projeto_integrador3/src/responses_model.dart';

class EmergencyDentistsList extends StatefulWidget {
  const EmergencyDentistsList({super.key});

  @override
  State<EmergencyDentistsList> createState() => _EmergencyDentistsListState();
}

class _EmergencyDentistsListState extends State<EmergencyDentistsList> {
  final userData = Authentication.retrieveLocalInfo();

  String? emergencyId;

  final Stream<QuerySnapshot> _responsesStream = Responses.getResponsesStream();

  @override
  initState() {
    Emergency.getEmergencyId().then((value) {
      emergencyId = value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          child: StreamBuilder(
            stream: _responsesStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              var docs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  if (docs[index]["rescuerUid"] == emergencyId) {
                    return SizedBox(
                      height: 400,
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(docs[index].get("professionalName")),
                        subtitle: const Text("13.6 km de você"),
                        trailing: TextButton(
                          onPressed: () {
                            openProfessionalDialog(
                              professionalUid:
                                  docs[index].get("professionalUid"),
                              distance: 13.6,
                              responseId: docs[index].id,
                            );
                          },
                          child: const Text(
                            "Ver mais",
                            softWrap: true,
                          ),
                        ),
                      ),
                    );
                  } else if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum dentista foi encontrado até o momento',
                      ),
                    );
                  } else {
                    return null;
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  openProfessionalDialog({
    required String professionalUid,
    required double distance,
    required String responseId,
  }) async {
    await FirebaseFirestore.instance
        .collection('profiles')
        .doc(professionalUid)
        .get()
        .then(
      (professionalValue) async {
        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(professionalUid)
            .collection('addresses')
            .where("primary", isEqualTo: true)
            .get()
            .then(
          (professionalAddress) {
            showDialog(
              context: context,
              useSafeArea: true,
              builder: (BuildContext context) => Dialog.fullscreen(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Colors.redAccent,
                      secondary: Colors.black54,
                    ),
                  ),
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text('Informações do dentista'),
                      centerTitle: true,
                    ),
                    body: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.network(professionalValue["urlImg"]),
                        Text(professionalValue["name"].toString()),
                        Text("CRO ${professionalValue["cro"].toString()}"),
                        Text(
                            "${professionalAddress.docs[0]["street"]}, ${professionalAddress.docs[0]["neighborhood"]}, ${professionalAddress.docs[0]["city"]} - ${professionalAddress.docs[0]["state"]} - CEP ${professionalAddress.docs[0]["zipeCode"]}"),
                        Text("$distance km de você"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              onPressed: () {
                                Responses.rejectProfessional(
                                    responseId: responseId);
                              },
                              child: const Text('Recusar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Responses.acceptProfessional(
                                    emergencyId: emergencyId!,
                                    professionalUid:
                                        professionalValue["authUid"]);
                              },
                              child: const Text(
                                'Aceitar',
                                style: TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
