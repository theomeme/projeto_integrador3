import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_integrador3/src/emergency/emergency_viewmodel.dart';

import 'emergency_dentists_list.dart';

class EmergencyUpload extends StatefulWidget {
  final List<String> emergencyPhotosPath;
  final DocumentSnapshot emergencyRef;

  const EmergencyUpload({
    required this.emergencyPhotosPath,
    required this.emergencyRef,
    super.key,
  });

  @override
  State<EmergencyUpload> createState() => _EmergencyUploadState();
}

class _EmergencyUploadState extends State<EmergencyUpload> {
  double uploadProgress = 0.0;
  String uploadLabel = '';

  final emergencyViewModel = EmergencyViewModel();

  @override
  void initState() {
    emergencyViewModel
        .uploadImages(widget.emergencyPhotosPath, widget.emergencyRef, (value) {
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
        title: const Text('Enviando fotos do acidente'),
        backgroundColor: Colors.redAccent,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.redAccent,
            secondary: Colors.black54,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Text(uploadLabel),
              LinearProgressIndicator(
                value: uploadProgress,
              )
            ],
          ),
        ),
      ),
    );
  }
}
