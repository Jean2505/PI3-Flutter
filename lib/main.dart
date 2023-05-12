import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Esse widget é a raiz do aplicativo.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeethKids',
      theme: ThemeData(
        // Esse é o tema da sua aplicação.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'TeethKids'),

    );
  }
}

class CadastroEmergencia extends StatefulWidget {
  const CadastroEmergencia({super.key, required this.title});

  final String title;

  @override
  State<CadastroEmergencia> createState() => _CadastroEmergenciaState();
}

class _CadastroEmergenciaState extends State<CadastroEmergencia> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Aqui, pegamos o valor do objeto MyHomePage que foi criado pelo método App.build
        //  e o usamos para definir o título da nossa appbar.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Digite seu nome',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Digite seu número do celular',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print('botão pressionado');
                },
                child: Text('Nova emergência'),
              ),
            ],
        ),
       ),
      );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    // Esse método é executado novamente toda vez setState é chamado
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Aqui, pegamos o valor do objeto MyHomePage que foi criado pelo método App.build
        //  e o usamos para definir o título da nossa appbar.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CadastroEmergencia(title: 'Cadastrar emergência',)),
                  );
                },
                child: Text('Nova emergência'),
            ),
          ],
        ),
      ),
    );
  }
}
