import 'package:firebase_authentication/firebase_authentication.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  userAuth();
  runApp(const MyApp());
}

Future<void> userAuth() async{
  try {
     final userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    print("Signed in with temporary account.");
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case "operation-not-allowed":
        print("Anonymous auth hasn't been enabled for this project.");
        break;
      default:
        print("Unknown error.");
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.bottomCenter,
          margin: const EdgeInsets.only(top: 15, bottom: 24),
          child: FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CadastroEmergencia(
                          title: 'Cadastrar emergência',
                        )
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sos),
                Padding(
                  padding: EdgeInsets.all(13),
                  child: Text(
                    'Solicitar Socorro',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            ),


          ),
        ),
      ],
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
  XFile? imagem;
  File? imagemSelecionada;
  //referencia para a coleção no banco
  CollectionReference emergencias = FirebaseFirestore.instance.collection('emergencias');
  //controller pra observar os TextFormField.
  final myNomeController = TextEditingController();
  final myTelefoneController = TextEditingController();
  final _formNomeKey = GlobalKey<FormState>();
  final _formTelefoneKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                    Text('Preencha com suas informações', style: TextStyle(fontSize: 20, color: Colors.deepPurple, fontStyle: FontStyle.italic),),
                  ],
                ),
              ),
              Padding(
                key: _formNomeKey,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nome Completo:', style: TextStyle(fontSize: 18, color: Colors.black87),),
                    TextFormField(
                      controller: myNomeController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe um nome';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_circle_sharp),
                        labelText: 'Digite seu nome',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                key: _formTelefoneKey,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Telefone:', style: TextStyle(fontSize: 18, color: Colors.black87),),
                    TextFormField(
                      controller: myTelefoneController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe um nome';
                         }
                        return null;
                       },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                        labelText: 'Digite seu número do celular',
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.bottomCenter,
                    margin: const EdgeInsets.only(top: 5, bottom: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: [
                          FilledButton(
                            onPressed: () async{
                              imagem = await pegarImagemCamera();
                            },
                            child: const Text('Tirar Foto'),
                          ),
                          const Text('Ou', style: TextStyle(fontSize: 14, color: Colors.deepPurple),),
                          OutlinedButton(
                            onPressed: () async {
                              imagem = await pegarImagemGaleria();
                            },
                            child: const Text('Foto da galeria'),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                enviarInfo(myNomeController.text, myTelefoneController.text, imagem);
                              },
                              child: const Text('Enviar emergência'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //tentativa de fazer imagem ir para o storage
  Future<XFile?> pegarImagemGaleria() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagem = await _picker.pickImage(source: ImageSource.gallery);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imagem salva!')),
    );
    return imagem;
    //pasta de imagem no storage.
    /*if (imagemTemporaria != null) {
      setState(() {
        imagemSelecionada = File(imagemTemporaria.path);
      });
    }
     */
  }

   Future<XFile?> pegarImagemCamera() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagem = await _picker.pickImage(source: ImageSource.camera);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imagem da camera salva!')),
    );
    return imagem;
  }

  Future<void>enviarInfo(String nome, String telefone, XFile? imagem1) async {
    final dataHora = "${DateTime.timestamp().day}/${DateTime.timestamp().month}/${DateTime.timestamp().year} ${DateTime.timestamp().hour}:${DateTime.timestamp().minute}";
    final fcm = await FirebaseMessaging.instance.getToken();
    final img1 = "images/img-${DateTime.now().toString()}.jpg";
    try {
      await FirebaseStorage.instance.ref().child("/$img1").putFile(File(imagem1!.path));
    } on FirebaseException catch (e) {
      throw Exception('Erro: ${e.code}');
    }

    final result = await FirebaseFunctions.instanceFor(region: 'southamerica-east1').httpsCallable("addEmergencia").call({
      'nome': nome,
      'tel': telefone,
      'uid': FirebaseAuth.instance.currentUser?.uid,
      'fcmToken': fcm,
      'Foto1': img1,
      'Foto2': "a",
      'Foto3': "a",
      'dataHora': dataHora
    }).then((value) => print("Dados enviados."))
        .catchError((error) => print("Erro ao enviar: $error"));
  }
}

class dentistaAceite extends StatefulWidget {
  const dentistaAceite({super.key});

  @override
  _dentistaAceiteState createState() {
    return _dentistaAceiteState();
  }
}

class _dentistaAceiteState extends State<dentistaAceite> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Localizando Dentistas"),
        ),
        body: Center(
        child:
    );
  }

  Future<void> atualizarLista {

  }
}

