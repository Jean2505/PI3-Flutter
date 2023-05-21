import 'package:firebase_authentication/firebase_authentication.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/src/widgets/framework.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  userAuth();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('Got a message whilst in the foreground!');
  //   print('Message data: ${message.data}');
  //   Navigator.push(context,
  //     MaterialPageRoute(builder: (context) => const listaDentistas()),
  //   );
  //
  //   if (message.notification != null) {
  //     print('Message also contained a notification: ${message.notification}');
  //   }
  // });
  runApp( const MyApp(),
  );
}

// class dadosDentista {
//
//   late String nome;
//   late String cv;
//
//   dentista({required String nome, required String cv})
//
// }
/*class NotificacaoFirebase {
  Future<void> initialize() async {

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    print("aaaaaaaaaaaaa");
  }

  mensagemNotificacao() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }
}
*/
Future<void> userAuth() async {
  try {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
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
          title: const Text(
            'Teeth Kids',
          ),
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
                        )),
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
  /*void initState() {
    super.initState();
    initializeFirebaseMessaging();
  }*/

  /*initializeFirebaseMessaging() async {
    await Provider.of<NotificacaoFirebase>(BuildContext as BuildContext,
            listen: true)
        .initialize();
  }*/

  final loading = ValueNotifier<bool>(false);
  ImagePicker imagePicker = ImagePicker();
  XFile? imagem;
  File? imagemSelecionada;

  //referencia para a coleção no banco
  CollectionReference emergencias =
      FirebaseFirestore.instance.collection('emergencias');

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
      body: Stack(
        children: [
          Center(
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
                        Text(
                          'Preencha com suas informações',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.deepPurple,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    key: _formNomeKey,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nome Completo:',
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                        TextFormField(
                          controller: myNomeController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe um nome';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Telefone:',
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                        TextFormField(
                          controller: myTelefoneController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe um nome';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                            labelText: 'Digite seu número do celular',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
                            onPressed: () async {
                              imagem = await pegarImagemCamera();
                            },
                            child: const Text('Tirar Foto'),
                          ),
                          const Text(
                            'Ou',
                            style: TextStyle(
                                fontSize: 14, color: Colors.deepPurple),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              imagem = await pegarImagemGaleria();
                            },
                            child: const Text('Foto da galeria'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: OutlinedButton(
                              onPressed: () {
                                enviarInfo(myNomeController.text,
                                    myTelefoneController.text, imagem);
                                !loading.value
                                    ? loading.value = !loading.value
                                    : null;
                                FirebaseMessaging.onMessage.listen((RemoteMessage message) {
                                  print('Got a message whilst in the foreground!');
                                  print('Message data: ${message.data}');
                                  Navigator.push(this.context,
                                    MaterialPageRoute(builder: (context) => const listaDentistas()),
                                  );

                                  if (message.notification != null) {
                                    print('Message also contained a notification: ${message.notification}');
                                  }
                                });
                              },
                              child: AnimatedBuilder(
                                  animation: loading,
                                  builder: (context, _) {
                                    return loading.value
                                        ? const Row(
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 20),
                                                child: Text(
                                                  'Procurando Dentistas',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Text(
                                              'Enviar Emergência',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          );
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  //tentativa de fazer imagem ir para o storage
  Future<XFile?> pegarImagemGaleria() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagem = await _picker.pickImage(source: ImageSource.gallery);

    //pasta de imagem no storage.
    if (imagem != null) {
      setState(() {
        imagemSelecionada = File(imagem.path);
      });
    }
    return imagem;
  }

  Future<XFile?> pegarImagemCamera() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagem = await _picker.pickImage(source: ImageSource.camera);
    return imagem;
  }

  Future<void> enviarInfo(String nome, String telefone, XFile? imagem1) async {
    final dataHora =
        "${DateTime.timestamp().day}/${DateTime.timestamp().month}/${DateTime.timestamp().year} ${DateTime.timestamp().hour}:${DateTime.timestamp().minute}";
    final fcm = await FirebaseMessaging.instance.getToken();
    final img1 = "images/img-${DateTime.now().toString()}.jpg";
    try {
      await FirebaseStorage.instance
          .ref()
          .child("/$img1")
          .putFile(File(imagem1!.path));
    } on FirebaseException catch (e) {
      throw Exception('Erro: ${e.code}');
    }

    final result =
        await FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable("addEmergencia")
            .call({
              'nome': nome,
              'tel': telefone,
              'uid': FirebaseAuth.instance.currentUser?.uid,
              'fcmToken': fcm,
              'Foto1': img1,
              'Foto2': "a",
              'Foto3': "a",
              'dataHora': dataHora
            })
            .then((value) => print("Dados enviados."))
            .catchError((error) => print("Erro ao enviar: $error"));
  }
}

class listaDentistas extends StatefulWidget {
    const listaDentistas({super.key});

   @override
   _listaDentistasState createState() => _listaDentistasState();
}

class _listaDentistasState extends State<listaDentistas> {

    final List<String> dentistas = <String>['A', 'B', 'C'];
    final List<int> colorCodes = <int>[600, 500, 100];

   @override
   Widget build(BuildContext context) {
     return ListView.separated(
       padding: const EdgeInsets.all(8),
       itemCount: dentistas.length,
       itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 50,
            color: Colors.cyan[colorCodes[index]],
            child: Center(child: Text('Dentista ${dentistas[index]}')),
          );
       },
       separatorBuilder: (BuildContext context, int index) => const Divider(),
     );
   }
}
