import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:projeto_integrador3/src/authentication.dart';
import 'package:projeto_integrador3/src/emergency/emergency_model.dart';
import 'package:projeto_integrador3/src/splash/splash_page.dart';

import 'emergency_dentists_list.dart';

class EmergencyCreating extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final Position location;
  final List<String> emergencyPhotosPath;

  const EmergencyCreating({
    required this.name,
    required this.phoneNumber,
    required this.location,
    required this.emergencyPhotosPath,
    super.key,
  });

  @override
  State<EmergencyCreating> createState() => _EmergencyCreatingState();
}

class _EmergencyCreatingState extends State<EmergencyCreating> {
  double uploadProgress = 0.0;
  String uploadLabel = '';

  @override
  void initState() {
    Emergency().makeEmergency(widget.emergencyPhotosPath, widget.name,
        widget.phoneNumber, widget.location, (value) {
      setState(() {
        uploadProgress = value;
      });
    }, (value) {
      setState(() {
        uploadLabel = value;
      });
    }, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EmergencyDentistsList(),
        ),
      );
    });
    super.initState();
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
        title: const Text('Abrindo chamado'),
        centerTitle: true,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(uploadLabel),
              LinearPercentIndicator(
                progressColor: Colors.redAccent,
                backgroundColor: Colors.black12,
                percent: uploadProgress,
                lineHeight: 25,
                center: Text(
                  "${uploadProgress*100}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.black45,
                  ),
                ),
                barRadius: const Radius.circular(8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
