import 'package:flutter/material.dart';
import 'package:projeto_integrador3/home/home_page.dart';
import 'package:projeto_integrador3/main.dart';
import 'package:projeto_integrador3/waiting.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyFormPage extends StatefulWidget {
  const EmergencyFormPage({super.key});

  @override
  State<EmergencyFormPage> createState() => _EmergencyFormPageState();
}

class _EmergencyFormPageState extends State<EmergencyFormPage> {
  ImagePicker imagePicker = ImagePicker();
  File? imagemSelecionada;
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  int _activeStepIndex = 0;
  double _uploadProgress = 0.0;
  double _uploadProgressText = 0.0;

  CollectionReference nomes =
      FirebaseFirestore.instance.collection('emergencies');

  String downloadUrl = '';

  List<Step> stepList() => [
        Step(
          state: _activeStepIndex <= 0 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 0,
          title: const Text('Fotos'),
          content: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Primeiro precisamos de uma foto da area acidentada...',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt),
                  TextButton(
                    onPressed: () {
                      getImageFromCamera();
                    },
                    child: const Text(
                      'Tirar Foto',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  const Icon(Icons.upload),
                  TextButton(
                    onPressed: () {
                      String uniqueFileName =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      final storageRef = FirebaseStorage.instance.ref();
                      final imageRef = storageRef
                          .child('EMERGENCIES/PHOTOS/$uniqueFileName.jpg');
                      final uploadTask =
                          imageRef.putFile(File(imagemSelecionada!.path));

                      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
                        setState(() {
                          _uploadProgress =
                              snapshot.bytesTransferred / snapshot.totalBytes;
                          // _uploadProgressText = (snapshot.bytesTransferred /
                          //         snapshot.totalBytes) *
                          //     100;
                        });
                      });

                      uploadTask.whenComplete(() {
                        imageRef.getDownloadURL().then((url) {
                          // Aqui está a URL de download do arquivo
                          downloadUrl = url.toString();
                          print("URL = $downloadUrl");
                        }).catchError((error) {
                          // Manipule erros ao obter a URL de download
                          print("Erro ao obter a URL de download: $error");
                        });
                      });
                    },
                    child: const Text(
                      'Enviar foto',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: Colors.grey,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.red),
                      minHeight: 20,
                    ),
                  ),
                  Text(
                    '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ],
              ),
              if (_uploadProgress == 1)
                const Text(
                  'Upload concluído!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              // LinearProgressIndicator(
              //   value: _uploadProgress,
              //   minHeight: 10,
              //   backgroundColor: Colors.grey,
              //   valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              // ),
              // const SizedBox(height: 8),
              // if (_uploadProgress == 1)
              //   const Text(
              //     'Upload concluído!',
              //     style: TextStyle(
              //       fontSize: 14,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
            ],
          ),
        ),
        Step(
          state: _activeStepIndex <= 1 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 1,
          title: const Text('Conta'),
          content: Column(
            children: [
              const Text(
                'Agora precisamos de alguns dados...',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Nome completo'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: '+55 99999-9999'),
                ),
              )
            ],
          ),
        ),
        Step(
          state: _activeStepIndex <= 2 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 2,
          title: const Text('Confirmacao'),
          content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Por favor confirme se os dados estao corretos...',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 22,
                    ),
                  ),
                ),
                const Text(
                  'Nome completo:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${nameController.text}',
                  style: const TextStyle(fontSize: 20),
                ),
                const Text(
                  'Numero:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${numberController.text}',
                  style: const TextStyle(fontSize: 20),
                ),
              ]),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> emergencyData = {
      'dateTime': DateTime.now().toString(),
      'emergencyId': 'm7YaY7RCB23EnQdmewSM',
      'location': [-22.865334, -47.058264],
      'name': nameController.text,
      'phone': numberController.text,
      'photos': [
        downloadUrl,
      ],
      'status': 'waiting',
    };
    Future<void> adicionarNome() {
      return nomes
          .add(emergencyData)
          // ignore: avoid_print
          .then((value) => print("Emergencia adicionada"))
          // ignore: avoid_print
          .catchError((error) => print("Erro ao adicionar: $error"));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        title: const Text('Solicitando ajuda'),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _activeStepIndex,
        steps: stepList(),
        onStepContinue: () {
          if (_activeStepIndex < (stepList().length - 1)) {
            _activeStepIndex++;
          } else {
            adicionarNome();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoadingPage()),
            );
          }
          setState(() {});
        },
        onStepCancel: () {
          if (_activeStepIndex == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
          } else {
            _activeStepIndex--;
            setState(() {});
          }
        },
      ),
    );
  }

  getImageFromCamera() async {
    final XFile? imagemTemporaria =
        await imagePicker.pickImage(source: ImageSource.camera);
    if (imagemTemporaria != null) {
      setState(() {
        imagemSelecionada = File(imagemTemporaria.path);
      });
    }
    print(imagemSelecionada!.path);
  }
}
