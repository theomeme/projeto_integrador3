import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:io';

class EmergencyFormPage extends StatefulWidget {
  const EmergencyFormPage({super.key});

  @override
  State<EmergencyFormPage> createState() => _EmergencyFormPageState();
}

class _EmergencyFormPageState extends State<EmergencyFormPage> {
  int _index = 0;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  ImagePicker imagePicker = ImagePicker();
  File? imagemSelecionada;

  List<String> photosPath = [];
  late DocumentReference emergencyDocDraft;

  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
  );

  List<Step> emergencySteps() => [
        Step(
          state: _index == 0 ? StepState.indexed : StepState.complete,
          isActive: _index == 0,
          title: const Text('Fotos'),
          content: Column(
            children: [
              const Text(
                'Precisamos de algumas fotos',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 22,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Para você solicitar ajuda precisamos que você tire as fotos listadas abaixo.',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 390,
                child: ListView(
                  children: [
                    Card(
                      child: Column(
                        children: [
                          const ListTile(
                            title: Text('Local acidentado'),
                            subtitle: Text(
                              'Tire uma foto do dente fraturado.',
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: AbsorbPointer(
                                  absorbing:
                                      (photosPath.isEmpty) ? true : false,
                                  child: TextButton(
                                    onPressed: () {
                                      openImageDialog(imagePath: photosPath[0]);
                                    },
                                    child: Text(
                                      (photosPath.isEmpty) ? '' : 'Visualizar',
                                      style: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: TextButton(
                                  onPressed: () {
                                    getImageFromCamera(imageIndex: 0);
                                  },
                                  child: Text(
                                    (photosPath.isEmpty)
                                        ? 'Tirar foto'
                                        : 'Alterar foto',
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        children: [
                          const ListTile(
                            title: Text('Documento do socorrista'),
                            subtitle: Text(
                              'Tire uma foto do documento do socorrista.',
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: AbsorbPointer(
                                  absorbing:
                                      (photosPath.length >= 2) ? false : true,
                                  child: TextButton(
                                    onPressed: () {
                                      openImageDialog(imagePath: photosPath[1]);
                                    },
                                    child: Text(
                                      (photosPath.length >= 2)
                                          ? 'Visualizar'
                                          : '',
                                      style: const TextStyle(
                                          color: Colors.black45),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: TextButton(
                                  onPressed: () {
                                    if (photosPath.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Tire as fotos anteriores primeiro.'),
                                        ),
                                      );
                                    } else {
                                      getImageFromCamera(imageIndex: 1);
                                    }
                                  },
                                  child: Text(
                                    (photosPath.length >= 2)
                                        ? 'Alterar foto'
                                        : 'Tirar foto',
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        children: [
                          const ListTile(
                            title: Text('Documento do socorrista e acidentado'),
                            subtitle: Text(
                              'Tire uma foto do documento do socorrista ao lado do acidentado.',
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: AbsorbPointer(
                                  absorbing:
                                      (photosPath.length >= 3) ? false : true,
                                  child: TextButton(
                                    onPressed: () {
                                      openImageDialog(imagePath: photosPath[2]);
                                    },
                                    child: Text(
                                      (photosPath.length >= 3)
                                          ? 'Visualizar'
                                          : '',
                                      style: const TextStyle(
                                          color: Colors.black45),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: TextButton(
                                  onPressed: () {
                                    if (photosPath.length < 2) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Tire as fotos anteriores primeiro.'),
                                        ),
                                      );
                                    } else {
                                      getImageFromCamera(imageIndex: 2);
                                    }
                                  },
                                  child: Text(
                                    (photosPath.length >= 2)
                                        ? 'Alterar foto'
                                        : 'Tirar foto',
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Step(
          state: (_index > 1) ? StepState.complete : StepState.indexed,
          isActive: _index == 1,
          title: const Text('Contato'),
          content: Column(
            children: [
              const Text(
                'Precisamos de algumas informações para entrar em contato com você.',
                style: TextStyle(
                  color: Colors.black45,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person),
                      ),
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value!.isEmpty ||
                            !RegExp(r'^[a-z A-Zá-úÁ-Ú]+$').hasMatch(value)) {
                          return 'Preencha o campo com seu nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _phoneController,
                      inputFormatters: [phoneMask],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Telefone',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty ||
                            !RegExp(r'^[+]*[(][0-9]{2}[)]([-\s/0-9]{11})+$')
                                .hasMatch(value)) {
                          return 'Preencha seu telefone corretamente';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Step(
          isActive: _index == 2,
          title: const Text('Revisão'),
          content: const Column(
            children: [
              Text(
                'Confirme seus dados',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 26,
                ),
              ),
            ],
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Solicitando emergência',
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.redAccent)),
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: _index,
                steps: emergencySteps(),
                onStepCancel: () {
                  if (_index > 0) {
                    setState(() {
                      _index -= 1;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
                onStepContinue: () {
                  if (_index >= 0 && _index < emergencySteps().length - 1) {
                    //mudar pra switch case
                    if (_index == 1) {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _index += 1;
                        });
                      }
                    } else if (_index == 0) {
                      if (photosPath.length == 3) {
                        setState(() {
                          _index += 1;
                        });
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Tire todas as fotos primeiro.'),
                          ),
                        );
                      }
                    } else {
                      setState(() {
                        _index += 1;
                      });
                    }
                  }
                },
                onStepTapped: (int index) {
                  setState(() {
                    _index = index;
                  });
                },
                controlsBuilder:
                    (BuildContext context, ControlsDetails details) {
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: details.onStepCancel,
                          child: Text(_index > 0 ? 'Voltar' : 'Cancelar'),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(_index < 2 ? 'Avançar' : 'Abrir chamado'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  getImageFromCamera({required int imageIndex}) async {
    final XFile? tempImage =
        await imagePicker.pickImage(source: ImageSource.camera);
    if (tempImage != null) {
      setState(() {
        if (photosPath.isNotEmpty && photosPath.length >= imageIndex + 1) {
          photosPath[imageIndex] = tempImage.path;
        } else {
          photosPath.add(tempImage.path);
        }
      });
    }
  }

  openImageDialog({required String imagePath}) => showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.file(File(imagePath)),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Fechar'),
              )
            ],
          ),
        ),
      );
}
