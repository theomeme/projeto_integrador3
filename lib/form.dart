import 'package:flutter/material.dart';
import 'package:projeto_integrador3/main.dart';
import 'package:projeto_integrador3/waiting.dart';

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
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  int _activeStepIndex = 0;

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
                    const Icon(Icons.camera_alt),
                    const SizedBox(
                      width: 16,
                    ),
                    TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Enviar foto',
                          style: TextStyle(fontSize: 20),
                        ))
                  ],
                )
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
                )
              ]),
        ),
      ];

  @override
  Widget build(BuildContext context) {
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
            //TODO: Implementar o envio pro fire
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
}
