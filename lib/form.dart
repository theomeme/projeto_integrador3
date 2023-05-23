import 'package:flutter/material.dart';
import 'package:projeto_integrador3/main.dart';
import 'package:projeto_integrador3/waiting.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewFormPage extends StatelessWidget {
  const NewFormPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const NewForm(title: 'Emergencia'),
    );
  }
}

class NewForm extends StatefulWidget {
  const NewForm({super.key, required this.title});

  final String title;

  @override
  State<NewForm> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<NewForm> {
  ImagePicker imagePicker = ImagePicker();
  File? imagemSelecionada;
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  int _activeStepIndex = 0;
  double _uploadProgress = 0.0;
  CollectionReference nomes =
      FirebaseFirestore.instance.collection('emergencies');

  List<Step> stepList() => [
        Step(
            state:
                _activeStepIndex <= 0 ? StepState.editing : StepState.complete,
            isActive: _activeStepIndex >= 0,
            title: const Text('Fotos'),
            content: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Primeiro precisamos de uma foto da area acidentada...',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () {
                        getImageFromCamera();
                      },
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      onPressed: () {
                        uploadFile();
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
                LinearProgressIndicator(
                  value: _uploadProgress,
                  minHeight: 10,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
                const SizedBox(height: 8),
                if (_uploadProgress == 1)
                  const Text(
                    'Upload concluído!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            )),
        Step(
          state: _activeStepIndex <= 1 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 1,
          title: const Text('Conta'),
          content: Column(
            children: [
              const Text(
                'Agora precisamos de alguns dados...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
    Future<void> adicionarNome(String nome, String phone) {
      return nomes
          .add({'name': nome, 'phone': phone, 'status': 'draft'})
          // ignore: avoid_print
          .then((value) => print("Emergencia adicionada"))
          // ignore: avoid_print
          .catchError((error) => print("Erro ao adicionar: $error"));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _activeStepIndex,
        steps: stepList(),
        onStepContinue: () {
          if (_activeStepIndex < (stepList().length - 1)) {
            _activeStepIndex++;
          } else {
            adicionarNome(nameController.text, numberController.text);
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
                MaterialPageRoute(builder: (context) => const MyApp()));
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

  uploadFile() {
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child('EMERGENCIES/PHOTOS/$uniqueFileName.jpg');
    final uploadTask = imageRef.putFile(File(imagemSelecionada!.path));

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      setState(() {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
      });
    });

    uploadTask.whenComplete(() {
      imageRef.getDownloadURL().then((url) {
        // Aqui está a URL de download do arquivo
        String downloadUrl = url.toString();
        print("URL = $downloadUrl");
      }).catchError((error) {
        // Manipule erros ao obter a URL de download
        print("Erro ao obter a URL de download: $error");
      });
    });
  }
}
