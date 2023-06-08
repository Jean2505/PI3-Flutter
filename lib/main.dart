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
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
  //   print('Message data: ${message.data.values.elementAt(0)}');
  //   Navigator.push(this.context,
  //     MaterialPageRoute(builder: (context) => listaDentistas(nome: '${message.data.values.elementAt(1)}')),
  //   );
  //
  //   if (message.notification != null) {
  //     print('Message also contained a notification: ${message.notification}');
  //   }
  // });
  runApp( const MyApp(),
  );
}


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
      debugShowCheckedModeBanner: false,
      title: 'Teeth Kids',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
          fontFamily: 'AvenirNextLTPro'),
      home: const Scaffold(
        body: MyHomePage(),
      ),
    );
  } //Widget
} // MyA

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  // final String title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/fundo.png"), fit: BoxFit.cover,
                )
            )
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  alignment: Alignment.bottomCenter,
                  margin: const EdgeInsets.only(top: 15, bottom: 24),
                  child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.white)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CadastroEmergencia(
                              title: 'Cadastrar emergência',
                            )),
                      );
                    },
                    child: CircleAvatar(
                      radius: 150,
                      backgroundColor: Colors.transparent,
                      child: Image.asset('assets/botaofinal.png'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class Avaliacao extends StatefulWidget {
  const Avaliacao({super.key});

  @override
  State<Avaliacao> createState() => _AvaliacaoState();
}

class _AvaliacaoState extends State<Avaliacao> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Form(
            child: Column(
              children: [
                const Text(
                  "Avalie seu dentista",
                  style: TextStyle(fontSize: 20),
                ),
            RatingBar.builder(
              initialRating: 1,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                print(rating);
              },
            ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Comente sua experiência!"),
                ),
                ElevatedButton(onPressed: () {},
                  child: Text("Enviar"),
                ),
              ],
            )
        ),
      ),
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

  final colorAzulEscuro = const Color(0xff064066);
  final colorAzulClaro = const Color(0xff56a2d9);
  final colorAzulCinza = const Color(0xff91b5cf);
  final colorAmarelo = const Color(0xffffd803);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Center (
            child: Padding (
              padding: const EdgeInsets.only(top: 0),
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
                              color: Color(0xff064066),
                              fontFamily: 'AvenirNextLTPro-BoldCn',
                              fontStyle: FontStyle.normal),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    key: _formNomeKey,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(

                          controller: myNomeController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe um nome';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff56a2d9))
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff56a2d9))
                            ),
                            prefixIcon: Icon(
                                Icons.account_circle_sharp,
                                color: Color(0xff56a2d9),
                            ),
                            labelText: 'Digite seu nome',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    key: _formTelefoneKey,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: myTelefoneController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe um nome';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff56a2d9))
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff56a2d9))
                            ),
                            prefixIcon: Icon(
                                Icons.phone,
                                color: Color(0xff56a2d9),),
                            labelText: 'Digite seu número de celular',
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
                    margin: const EdgeInsets.only(top: 0, bottom: 64),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt_outlined,
                            color: Colors.white
                            ),
                            onPressed: () async {
                              imagem = await pegarImagemCamera();
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(140,45),
                              primary: Color(0xff56a2d9),
                            ),
                            label: const Text('Tirar foto',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'AvenirNextLTPro-BoldCn',
                              ),
                            ),

                          ),
                          const Text(
                            'Ou',
                            style: TextStyle(
                                fontSize: 14, color: Color(0xff064066)),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.photo,
                                color: Colors.white
                            ),
                            onPressed: () async {
                              imagem = await pegarImagemGaleria();
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(140,45),
                              primary: Color(0xff56a2d9),
                            ),
                            label: const Text('Foto salva',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'AvenirNextLTPro-BoldCn',
                              ),
                            ),

                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(200, 60),
                                side: BorderSide(
                                  width: 3,
                                  color: Color(0xff56a2d9),
                                ),
                                primary: Color(0xffffd803),
                              ),
                              onPressed: () {
                                enviarInfo(myNomeController.text,
                                    myTelefoneController.text, imagem);
                                !loading.value
                                    ? loading.value = !loading.value
                                    : null;
                                FirebaseMessaging.onMessage.listen((RemoteMessage message) {
                                  print('Got a message whilst in the foreground!');
                                  print('Message data: ${message.data['telefone']}');

                                  if(_nomesDentista.length < 5) {

                                    listaDadosDentista auxVar = listaDadosDentista(telefone: message.data['telefone'], cv: message.data['cv'], nome: message.data['nome']);

                                    _dadosDoDentista.add(auxVar);

                                    setState(() =>
                                        _nomesDentista.add(
                                            message.data['nome']));
                                  }
                                  if(_nomesDentista.length == 1) {

                                    Navigator.push(this.context,
                                      MaterialPageRoute(builder: (context) => listaDentistas())
                                    );

                                  }

                                  if(message.data != null){

                                    showModalBottomSheet(context: context, builder: (context) => Avaliacao());

                                  }

                                  print(_nomesDentista);

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
                                                    CircularProgressIndicator(
                                                      color: Color(0xff56a2d9),
                                                    ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 20),
                                                child: Text(
                                                  'Procurando dentistas',
                                                  style:
                                                      TextStyle(fontSize: 20,
                                                      color: Color(0xff56a2d9),),
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Text(
                                              'Solicitar emergência',
                                              style: TextStyle(fontSize: 20,
                                              color: Color(0xff56a2d9)),
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

  //função que pega imagem da galeria
  Future<XFile?> pegarImagemGaleria() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagem = await _picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      setState(() {
        imagemSelecionada = File(imagem.path);
      });
    }
    return imagem;
  }

  //função que pega a imagem tirada com a camera
  Future<XFile?> pegarImagemCamera() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagem = await _picker.pickImage(source: ImageSource.camera);
    return imagem;
  }

  Future<void> enviarInfo(String nome, String telefone, XFile? imagem1) async {
    final dataHora =
        "${DateTime.timestamp().day}/${DateTime.timestamp().month}/${DateTime.timestamp().year} ${DateTime.timestamp().hour}:${DateTime.timestamp().minute}";
    final fcm = await FirebaseMessaging.instance.getToken();
    final img1 =
        "images/img-${DateTime.timestamp().day.toString()}-${DateTime.timestamp().month.toString()}-${DateTime.timestamp()
          .year.toString()}-${DateTime.timestamp().hour.toString()}:${DateTime.timestamp().minute.toString()}:${DateTime.timestamp()
            .second.toString()}:${DateTime.timestamp().millisecond.toString()}.jpg";
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

    final List<int> colorCodes = <int>[600, 500, 100, 100, 100, 100];
    late Timer _everySecond;

    @override
    void initState() {
      super.initState();

        _everySecond = Timer.periodic(Duration(seconds: 5), (Timer t) {
          if(_nomesDentista.length != 5) {
            setState(() {});

          }
        });
    }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: const Text('Lista de dentistas'),
       ),
       body: ListView.separated(
         padding: const EdgeInsets.all(8),
         itemCount: _nomesDentista.length,
         itemBuilder: (BuildContext context, int index) {
           return GestureDetector(
             onTap: () =>
                 Navigator.push(this.context,
                   MaterialPageRoute(builder: (context) => dadosDentista(title: _nomesDentista[index], index: index)),
                 ),
             child: Container(
               decoration: BoxDecoration(
                 color: Color(0xff56a2d9),
                 border: Border.all(
                   width: 5,
                   color: Color(0xff064066),
                 ),
                 borderRadius: BorderRadius.all(Radius.circular(10)),
               ),
               height: 75,

               child: Column(
                 children: [
                   //Icon(Icons.arrow_forward_ios),
                   Center(
                     child: Text(
                       _nomesDentista[index],
                       style: const TextStyle(
                          fontFamily: 'AvenirNextLTPro-BoldCn',
                          fontSize: 25,
                       ),
                     ),
                   ),
                 ],
               ),
             ),
           );
         },
         separatorBuilder: (BuildContext context, int index) => const Divider(),
       ),
     );
   }
}

class dadosDentista extends StatefulWidget {
  const dadosDentista({super.key, required this.title, required this.index});

  final String title;
  final int index;

  @override
  _dadosDentistaState createState() => _dadosDentistaState();
}

class _dadosDentistaState extends State<dadosDentista> {

  List<String> rejeitados = <String>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Text(_dadosDoDentista[widget.index].telefone),
            Text(_dadosDoDentista[widget.index].cv),
            ElevatedButton(
                onPressed: () async {

                  var x = _dadosDoDentista.removeAt(widget.index);
                  _dadosDoDentista.forEach((element) {
                    rejeitados.add(element.nome);
                  });
                  escolherDentista(x, rejeitados);

                  Navigator.popUntil(context, ModalRoute.withName('/MyHomePage'));

                },
                child: const Text('Aceitar!'),
            ),
          ],
        ),
      )
    );
  }

  Future<void> escolherDentista(listaDadosDentista aceito, List<String> rejeitados) async {

    await FirebaseFunctions.instanceFor(region: 'southamerica-east1')
        .httpsCallable("escolheDentista")
          .call({
            'rej': rejeitados,
            'escolhido': aceito.nome,
          })
          .then((value) => print(value.data['status']))
            .catchError((error) => print("Erro ao enviar: $error"));
  }

}

class listaDadosDentista {

    late String nome;
    late String telefone;
    late String cv;

    listaDadosDentista({ required this.nome, required this.telefone, required this.cv});

}

final List<String> _nomesDentista = <String>[];
final List<listaDadosDentista> _dadosDoDentista = <listaDadosDentista>[];