import 'package:firebase_authentication/firebase_authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  tz.initializeTimeZones();
  final location = tz.getLocation('America/Sao_Paulo');
  print(location);
  tz.setLocalLocation(location);

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

                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const telaFinal())
                      );
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => const CadastroEmergencia(
                      //         title: 'Cadastrar emergência',
                      //       )),
                      // );
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
  const Avaliacao({super.key, required this.nome_socorrista, required this.uid_dentista});

  final String nome_socorrista;
  final String uid_dentista;

  @override
  State<Avaliacao> createState() => _AvaliacaoState();
}

class _AvaliacaoState extends State<Avaliacao> {

  //Controller que pega o texto da área de comentário
  final myComentarioDentController = TextEditingController();
  final myComentarioAppController = TextEditingController();

  //Variáveis que salvam a nota dada ao app e ao dentista
  var myRatingDent = 0.0;
  var myRatingApp = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Form(
            child: Column(
              children: [
                const Text(
                  "Avalie o aplicativo",
                  style: TextStyle(fontSize: 20),
                ),
                RatingBar.builder(
                  initialRating: 0,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    myRatingApp = rating;
                    print(rating);
                  },
                ),
                TextFormField(
                  maxLength: 280,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  controller: myComentarioAppController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, comente algo';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: "Comente sua experiência!"),
                ),

                const Text(
                  "Avalie seu dentista",
                  style: TextStyle(fontSize: 20),
                ),
                RatingBar.builder(
                  initialRating: 0,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    myRatingDent = rating;
                    print(rating);
                  },
                ),
                TextFormField(
                  maxLength: 280,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  controller: myComentarioDentController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, comente algo';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: "Comente sua experiência!"),
                ),
                ElevatedButton(onPressed: () {
                  print('${myRatingDent}, ${myRatingApp}, ${myComentarioDentController.text}, ${myComentarioAppController.text}');
                  enviaAvaliacao(widget.uid_dentista, widget.nome_socorrista, myRatingDent, myRatingApp, myComentarioDentController.text, myComentarioAppController.text);
                  Navigator.push(this.context,
                      MaterialPageRoute(builder: (context) => const telaFinal())
                  );
                },
                  child: const Text("Enviar"),
                ),
              ],
            )
        ),
      ),
    );
  }

  Future<void> enviaAvaliacao(String uidDent, String nomeSocorrista, double notaDent, double notaApp, String comentarioDent, String comentarioApp) async {

    await FirebaseFunctions.instanceFor(region: 'southamerica-east1')
        .httpsCallable("addAvaliacao")
          .call({
            'uidDentista': uidDent,
            'nome': nomeSocorrista,
            'aval': notaDent,
            'coment': comentarioDent,
            'avalApp': notaApp,
            'comentApp': comentarioApp,
        }).then((value) => print(value.data['status']))
            .catchError((error) => print("Erro ao enviar: $error"));
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
  XFile? imagem1;
  XFile? imagem2;
  XFile? imagem3;
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
                              imagem1 = await pegarImagemCamera_lesao();
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(140,45),
                              primary: Color(0xff56a2d9),
                            ),
                            label: const Text('Foto da lesão',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'AvenirNextLTPro-BoldCn',
                              ),
                            ),

                          ),

                          ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt_outlined,
                                color: Colors.white
                            ),
                            onPressed: () async {
                              imagem2 = await pegarImagemCamera_socorrista();
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(140,45),
                              primary: Color(0xff56a2d9),
                            ),
                            label: const Text('Foto do socorrista',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'AvenirNextLTPro-BoldCn',
                              ),
                            ),

                          ),

                          ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt_outlined,
                                color: Colors.white
                            ),
                            onPressed: () async {
                              imagem3 = await pegarImagemCamera_docSocorrista();
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(140,45),
                              primary: Color(0xff56a2d9),
                            ),
                            label: const Text('Foto do documento',
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
                                    myTelefoneController.text, imagem1, imagem2, imagem3);
                                !loading.value
                                    ? loading.value = !loading.value
                                    : null;
                                FirebaseMessaging.onMessage.listen((RemoteMessage message) {
                                  print('Got a message whilst in the foreground!');
                                  print('Message data: ${message.data}');

                                  if(message.data['text'] == 'aceita') {
                                    if (_nomesDentista.length < 5) {
                                      listaDadosDentista auxVar = listaDadosDentista(
                                          telefone: message.data['telefone'],
                                          cv: message.data['cv'],
                                          nome: message.data['nome']);

                                      _dadosDoDentista.add(auxVar);

                                      setState(() =>
                                          _nomesDentista.add(
                                              message.data['nome']));
                                    }
                                    if (_nomesDentista.length == 1) {
                                      Navigator.push(this.context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  listaDentistas())
                                      );
                                    }
                                  }

                                  if(message.data['text'] == 'localizacao'){

                                    Navigator.push(this.context,
                                        MaterialPageRoute(builder: (context) => Maps(lat: double.parse('${message.data['lat']}'),long: double.parse('${message.data['long']}')))
                                    );
                                  }
                                   if(message.data['text'] == 'finalizada'){

                                     showModalBottomSheet<dynamic>(context: context, builder: (context) => Avaliacao(nome_socorrista: myNomeController.text, uid_dentista: message.data['uid']));

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

  // //função que pega imagem da galeria
  // Future<XFile?> pegarImagemGaleria() async {
  //   final ImagePicker _picker = ImagePicker();
  //   XFile? imagem = await _picker.pickImage(source: ImageSource.gallery);
  //
  //   if (imagem != null) {
  //     setState(() {
  //       imagemSelecionada = File(imagem.path);
  //     });
  //   }
  //   return imagem;
  // } LEMBRAR DE APAGAR DEPOIS

  //função que pega a imagem tirada com a camera
  Future<XFile?> pegarImagemCamera_lesao() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagem1 = await _picker.pickImage(source: ImageSource.camera);
    return imagem1;
  }

  //função que pega a imagem tirada com a camera
  Future<XFile?> pegarImagemCamera_socorrista() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagem2 = await _picker.pickImage(source: ImageSource.camera);
    return imagem2;
  }

  //função que pega a imagem tirada com a camera
  Future<XFile?> pegarImagemCamera_docSocorrista() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagem3 = await _picker.pickImage(source: ImageSource.camera);
    return imagem3;
  }

  Future<void> enviarInfo(String nome, String telefone, XFile? imagem1, XFile? imagem2, XFile? imagem3) async {
    final dataHora =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}";
    final fcm = await FirebaseMessaging.instance.getToken();
    final img1 =
        "images/img-${DateTime.now().day.toString()}-${DateTime.now().month.toString()}-${DateTime.now()
          .year.toString()}-${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}:${DateTime.now()
            .second.toString()}:${DateTime.now().millisecond.toString()}.jpg";
    try {
      await FirebaseStorage.instance
          .ref()
          .child("/$img1")
          .putFile(File(imagem1!.path));
    } on FirebaseException catch (e) {
      throw Exception('Erro: ${e.code}');
    }

    final img2 =
        "images/img-${DateTime.now().day.toString()}-${DateTime.now().month.toString()}-${DateTime.now()
        .year.toString()}-${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}:${DateTime.now()
        .second.toString()}:${DateTime.now().millisecond.toString()}.jpg";
    try {
      await FirebaseStorage.instance
          .ref()
          .child("/$img2")
          .putFile(File(imagem2!.path));
    } on FirebaseException catch (e) {
      throw Exception('Erro: ${e.code}');
    }

    final img3 =
        "images/img-${DateTime.now().day.toString()}-${DateTime.now().month.toString()}-${DateTime.now()
        .year.toString()}-${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}:${DateTime.now()
        .second.toString()}:${DateTime.now().millisecond.toString()}.jpg";
    try {
      await FirebaseStorage.instance
          .ref()
          .child("/$img3")
          .putFile(File(imagem3!.path));
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
              'Foto2': img2,
              'Foto3': img3,
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
  late final listaDadosDentista x;
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

                  x = _dadosDoDentista.removeAt(widget.index);
                  _dadosDoDentista.forEach((element) {
                    rejeitados.add(element.nome);
                  });
                  escolherDentista(x, rejeitados);

                  //Navigator.popUntil(context, ModalRoute.withName('/MyHomePage'));

                },
                child: const Text('Aceitar!'),
            ),
            ElevatedButton(onPressed: () async {

              if (await Permission.location.request().isGranted){

                final posicao = await Geolocator.getCurrentPosition();

                enviaLocalizacao(posicao.latitude.toString(), posicao.longitude.toString(), x.nome);

              }
            },
                child: const Text('Enviar localização'),
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

  Future<void> enviaLocalizacao(String lat, String long, String nome) async {

    await FirebaseFunctions.instanceFor(region: 'southamerica-east1')
        .httpsCallable("enviaLocalizacaoSocorrista")
          .call({
            'lat': lat,
            'long': long,
            'nome': nome,
          })
            .then((value) => print(value.data['status']))
              .catchError((error) => print("Erro ao enviar: $error"));
  }
}

class Maps extends StatefulWidget {
  const Maps({super.key, required this.lat, required this.long});

  final double lat;
  final double long;

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  late GoogleMapController mapController;


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // final LatLng localUsuario = pegarLocalizacao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.lat as double, widget.long as double),
          zoom: 15,
        ),
        markers: {
           Marker(
            markerId: MarkerId("source"),
            position: LatLng(widget.lat as double, widget.long as double),
          )
        },
      ),
    );
  }
}

class telaFinal extends StatelessWidget {
  const telaFinal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Clique no botão para fechar o aplicativo!"),

                ElevatedButton(onPressed: () {
                  SystemNavigator.pop();
                  },
                  child: const Text("Sair"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class listaDadosDentista {

    late String nome;
    late String telefone;
    late String cv;

    listaDadosDentista({ required this.nome, required this.telefone, required this.cv});

}

pegarLocalizacao() async {
  Position posicao = await Geolocator.getCurrentPosition();
  final localizacao = LatLng(
      posicao.latitude.toDouble(),
      posicao.longitude.toDouble());
  return localizacao;
}

final List<String> _nomesDentista = <String>[];
final List<listaDadosDentista> _dadosDoDentista = <listaDadosDentista>[];