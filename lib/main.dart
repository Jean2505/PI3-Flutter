import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Esse widget é a raiz do aplicativo.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teeth Kids',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Teeth Kids',),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyHomePage(title: 'Teeth Kids'),
            ],
          ),
        ),
      ),
    );
  } //Widget
} // MyA

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const CadastroEmergencia(
                    title: 'Cadastrar emergência',
                  )),
        );
      },
      child: const Text('Solicitar Socorro'),
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
  ImagePicker imagePicker = ImagePicker();
  File? imagemSelecionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Aqui, pegamos o valor do objeto MyHomePage que foi criado pelo método App.build
        //  e o usamos para definir o título da nossa appbar.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Caso futuramente temos que fazer a foto aparecer na tela
            // imagemSelecionada == null
            //     ? Container()
            //     : Image.file(imagemSelecionada!),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nome Completo:', style: TextStyle(fontSize: 18, color: Colors.deepPurple),),
                  TextField(
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Digite seu nome',
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Telefone:', style: TextStyle(fontSize: 18, color: Colors.deepPurple),),
                  TextField(
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Digite seu número do celular',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: () {
                      pegarImagemCamera();
                    },
                    child: const Text('Tirar Foto'),
                  ),
                  const Text('Ou', style: TextStyle(fontSize: 14, color: Colors.deepPurple),),
                  OutlinedButton(
                    onPressed: () {
                      pegarImagemGaleria();
                    },
                    child: const Text('Foto da galeria'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  pegarImagemGaleria() async {
    final PickedFile? imagemTemporaria =
        await imagePicker.getImage(source: ImageSource.gallery);
    if (imagemTemporaria != null) {
      setState(() {
        imagemSelecionada = File(imagemTemporaria.path);
      });
    }
  }

  pegarImagemCamera() async {
    final PickedFile? imagemTemporaria =
        await imagePicker.getImage(source: ImageSource.camera);
    if (imagemTemporaria != null) {
      setState(() {
        imagemSelecionada = File(imagemTemporaria.path);
      });
    }
  }
}
