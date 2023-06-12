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
                      height: 300,
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(docs[index]['professionalName']),
                        subtitle: const Text("13.6 km de você"),
                        trailing: TextButton(
                          onPressed: () {},
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
}
