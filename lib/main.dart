import 'package:firebase_authentication/firebase_authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
  runApp(
    const MyApp(),
  );
}

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage("assets/fundo.png"),
              fit: BoxFit.cover,
            ))),
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
  const Avaliacao(
      {super.key, required this.nome_socorrista, required this.uid_dentista});

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
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Avalie o aplicativo",
              style: TextStyle(fontSize: 20),
            ),

            // Este é o construtor do RatingBar usado no modal de avaliação.
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

              // Cada vez que uma estrela é clicada, ocorre um update e a cada update a rating nova é guardada.
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
              decoration:
                  const InputDecoration(labelText: "Comente sua experiência!"),
            ),
            const SizedBox(height: 10),
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
              decoration:
                  const InputDecoration(labelText: "Comente sua experiência!"),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text(
                        'Avaliações enviadas. Obrigado por usar o app!')));

                // Quando o botão é pressionado, envia os cometários e as notas para o banco de dados.
                enviaAvaliacao(
                    widget.uid_dentista,
                    widget.nome_socorrista,
                    myRatingDent,
                    myRatingApp,
                    myComentarioDentController.text,
                    myComentarioAppController.text);
                // Navigator.push(this.context,
                //     MaterialPageRoute(builder: (context) => const telaFinal())
                // );

                // Fecha o modal.
                Navigator.pop(context);
              },
              child: const Text("Enviar"),
            ),
            const SizedBox(height: 269),
          ],
        )),
      ),
    );
  }

  // Função que envia a avaliação do app e do dentista para o banco utilizando a function addAvaliacao.
  Future<void> enviaAvaliacao(
      String uidDent,
      String nomeSocorrista,
      double notaDent,
      double notaApp,
      String comentarioDent,
      String comentarioApp) async {
    await FirebaseFunctions.instanceFor(region: 'southamerica-east1')
        .httpsCallable("addAvaliacao")
        .call({
          'uidDentista': uidDent,
          'nome': nomeSocorrista,
          'aval': notaDent,
          'coment': comentarioDent,
          'avalApp': notaApp,
          'comentApp': comentarioApp,
        })
        .then((value) => print(value.data['status']))
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
  // referência do loading utilizado quando está aguardando um dentista aceitar a emergência.
  final loading = ValueNotifier<bool>(false);

  // referência do ImagePicker.
  ImagePicker imagePicker = ImagePicker();

  // variáveis que guardam as fotos tiradas.
  XFile? imagem1;
  XFile? imagem2;
  XFile? imagem3;

  //referencia para a coleção no banco
  CollectionReference emergencias =
      FirebaseFirestore.instance.collection('emergencias');

  //controller pra observar os TextFormField.
  final myNomeController = TextEditingController();
  final myTelefoneController = TextEditingController();
  final _formNomeKey = GlobalKey<FormState>();
  final _formTelefoneKey = GlobalKey<FormState>();

  //referência para cores
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
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
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
                          // O validator verifica se o campo está vazio e evita que a emergência seja criada caso o valor seja null
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe um nome';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff56a2d9))),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff56a2d9))),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
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
                                borderSide:
                                    BorderSide(color: Color(0xff56a2d9))),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff56a2d9))),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Color(0xff56a2d9),
                            ),
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
                                color: Colors.white),
                            onPressed: () async {
                              imagem1 = await pegarImagemCamera_lesao();
                              // Esse snackbar espera a foto ser salva na variável para avisar o usuário.
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          const Text('Foto da lesão salva.')));
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(230, 45),
                              primary: Color(0xff56a2d9),
                            ),
                            label: const Text(
                              'Foto da lesão',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'AvenirNextLTPro-BoldCn',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                            height: 40,
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt_outlined,
                                color: Colors.white),
                            onPressed: () async {
                              imagem2 = await pegarImagemCamera_socorrista();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: const Text(
                                      'Foto com criança acidentada salva.')));
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(230, 45),
                              primary: Color(0xff56a2d9),
                            ),
                            label: const Text(
                              'Foto com criança',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'AvenirNextLTPro-BoldCn',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                            height: 40,
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt_outlined,
                                color: Colors.white),
                            onPressed: () async {
                              imagem3 = await pegarImagemCamera_docSocorrista();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: const Text(
                                          'Foto do documento salva.')));
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(230, 45),
                              primary: Color(0xff56a2d9),
                            ),
                            label: const Text(
                              'Foto do documento',
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
                                // Quando o botão é pressionado envia para o banco de dados essas informações.
                                enviarInfo(
                                    myNomeController.text,
                                    myTelefoneController.text,
                                    imagem1,
                                    imagem2,
                                    imagem3);
                                // Quando as informações forem enviadas, o botão de enviar mudará para um modo de loading
                                // enquanto um dentista não aceita a emergência
                                !loading.value
                                    ? loading.value = !loading.value
                                    : null;
                                // Listener do FirebaseMessaging que fica "escutando" as mensagens
                                // e executa ações baseado no 'text' delas.
                                FirebaseMessaging.onMessage
                                    .listen((RemoteMessage message) async {
                                  print(
                                      'Got a message whilst in the foreground!');
                                  print('Message data: ${message.data}');

                                  if (message.data['text'] == 'aceita') {
                                    if (_nomesDentista.length < 5) {
                                      // Quando uma emergência é aceita, certos dados da mensagem são guardadas
                                      // na numa variável do tipo listaDadosDentista.
                                      listaDadosDentista auxVar =
                                          listaDadosDentista(
                                              telefone:
                                                  message.data['telefone'],
                                              cv: message.data['cv'],
                                              nome: message.data['nome'],
                                              foto: message.data['foto']);

                                      // Depois de guardada na variável, os dados do dentista são salvos numa lista.
                                      _dadosDoDentista.add(auxVar);

                                      final storageRef =
                                          FirebaseStorage.instance.ref();

                                      // Referência para o Storage.
                                      final gsReference = await FirebaseStorage
                                          .instance
                                          .refFromURL(message.data['foto'])
                                          .getDownloadURL();

                                      print(gsReference.toString());

                                      final appDocDir =
                                          await getApplicationDocumentsDirectory();
                                      final filePath =
                                          "${appDocDir.absolute}/${message.data['foto']}";
                                      final file = File(filePath);

                                      // Guarda o URL da foto do dentista que aceitou a emergência numa lista.
                                      _fotoDentista.add(gsReference);

                                      // setState que atualiza a widget de lista de dentistas que aceitaram
                                      setState(() => _nomesDentista
                                          .add(message.data['nome']));
                                    }

                                    // Cria uma "rota" para a próxima widget quando há 1 item
                                    // na lista de nomes dos dentista que aceitaram
                                    if (_nomesDentista.length == 1) {
                                      Navigator.push(
                                          this.context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  listaDentistas()));
                                    }
                                  }

                                  // Muda dentistaLigou para true quando o socorrista recebe uma ligação
                                  if (message.data['text'] == 'ligacao') {
                                    dentistaLigou = true;
                                  }

                                  // Envia para a tela do Maps, mostrando a localização do dentista
                                  if (message.data['text'] == 'localizacao') {
                                    Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                            builder: (context) => Maps(
                                                lat: double.parse(
                                                    '${message.data['lat']}'),
                                                long: double.parse(
                                                    '${message.data['long']}'))));
                                  }

                                  // Quando o dentista finaliza a emergência, o socorrista é enviado
                                  // para a tela final e o modal de avaliação é aberto
                                  if (message.data['text'] == 'finalizada') {
                                    Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const telaFinal()));

                                    showModalBottomSheet<dynamic>(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) => Avaliacao(
                                            nome_socorrista:
                                                myNomeController.text,
                                            uid_dentista: message.data['uid']));
                                  }

                                  print(_nomesDentista);

                                  if (message.notification != null) {
                                    print(
                                        'Message also contained a notification: ${message.notification}');
                                  }
                                });
                              },

                              // Builder da animação de loading
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
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Color(0xff56a2d9),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Text(
                                              'Solicitar emergência',
                                              style: TextStyle(
                                                  fontSize: 20,
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

  // Função que envia os dados e fotos do socorrista para o banco
  Future<void> enviarInfo(String nome, String telefone, XFile? imagem1,
      XFile? imagem2, XFile? imagem3) async {
    final dataHora =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}";
    final fcm = await FirebaseMessaging.instance.getToken();
    final img1 =
        "images/img-${DateTime.now().day.toString()}-${DateTime.now().month.toString()}-${DateTime.now().year.toString()}-${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}:${DateTime.now().second.toString()}:${DateTime.now().millisecond.toString()}.jpg";
    try {
      await FirebaseStorage.instance
          .ref()
          .child("/$img1")
          .putFile(File(imagem1!.path));
    } on FirebaseException catch (e) {
      throw Exception('Erro: ${e.code}');
    }

    final img2 =
        "images/img-${DateTime.now().day.toString()}-${DateTime.now().month.toString()}-${DateTime.now().year.toString()}-${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}:${DateTime.now().second.toString()}:${DateTime.now().millisecond.toString()}.jpg";
    try {
      await FirebaseStorage.instance
          .ref()
          .child("/$img2")
          .putFile(File(imagem2!.path));
    } on FirebaseException catch (e) {
      throw Exception('Erro: ${e.code}');
    }

    final img3 =
        "images/img-${DateTime.now().day.toString()}-${DateTime.now().month.toString()}-${DateTime.now().year.toString()}-${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}:${DateTime.now().second.toString()}:${DateTime.now().millisecond.toString()}.jpg";
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

// Widget da lista de dentistas que aceitaram a emergência.
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

    // este timer "atualiza" a widget periodicamente para receber
    // novos dentistas que aceitaram.
    _everySecond = Timer.periodic(Duration(seconds: 5), (Timer t) {
      if (_nomesDentista.length != 5) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Lista de dentistas'),
      ),
      // ListView que mostra os dentistas
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: _nomesDentista.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            // Quando clica em um tile da lista, abre o widget de dados do dentista selecionado.
            onTap: () => Navigator.push(
              this.context,
              MaterialPageRoute(
                builder: (context) =>
                    dadosDentista(title: _nomesDentista[index], index: index),
              ),
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
              child: Row(
                children: [
                  Container(
                    width: 75,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(_fotoDentista[index]),
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Align(
                    alignment: Alignment.centerLeft,
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

// Widget de dados do dentista.
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
  late Timer _contaUmMin;
  final _statesController = MaterialStatesController();

  @override
  Widget build(BuildContext context) {
    _statesController.update(MaterialState.disabled, true);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              width: 140,
              height: 185,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  ),
                ),
                child: Image.network(
                  _fotoDentista[widget.index],
                  //fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(left: 15),
              alignment: Alignment.centerLeft,
              child: Text(
                'Telefone',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              padding: EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 3,
                  color: Colors.blue,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                _dadosDoDentista[widget.index].telefone,
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(left: 15),
              alignment: Alignment.centerLeft,
              child: Text(
                'Experiência profissional',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              padding: EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 3,
                  color: Colors.blue,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                _dadosDoDentista[widget.index].cv,
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width /
                  3, // Ajuste o tamanho do botão aqui
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  width: 2,
                  color: Colors.amber,
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 0), // Ajuste o tamanho do padding aqui
                ),
                onPressed: () async {
                  final snackBar = SnackBar(
                      content: const Text(
                          'O dentista escolhido não realizou uma ligação. Por favor escolha outro dentista.'));

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text('Dentista aceito. Aguarde contato.')));

                  _contaUmMin = Timer(Duration(seconds: 60), () {
                    if (dentistaLigou == false) {
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      print("falso");
                      Navigator.pop(context);
                    } else {
                      print("verdadeiro");
                      _statesController.update(MaterialState.disabled, false);
                    }
                  });

                  x = _dadosDoDentista.removeAt(widget.index);
                  _dadosDoDentista.forEach((element) {
                    rejeitados.add(element.nome);
                  });
                  escolherDentista(x, rejeitados);
                  rejeitarDentista(rejeitados);
                },
                child: const Text(
                  'Aceitar!',
                  style:
                      TextStyle(fontSize: 20), // Ajuste o tamanho da fonte aqui
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  width: 2,
                  color: Colors.amber,
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  disabledForegroundColor: Colors.grey,
                ),
                statesController: _statesController,
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Localização enviada ao dentista.')));

                  if (await Permission.location.request().isGranted) {
                    final posicao = await Geolocator.getCurrentPosition();
                    enviaLocalizacao(
                      posicao.latitude.toString(),
                      posicao.longitude.toString(),
                      x.nome,
                    );
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Enviar localização',
                      style: TextStyle(fontSize: 20),
                    ),
                    Icon(Icons.location_on), // Ícone de localização
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> escolherDentista(
      listaDadosDentista aceito, List<String> rejeitados) async {
    await FirebaseFunctions.instanceFor(region: 'southamerica-east1')
        .httpsCallable("escolheDentista")
        .call({
          //'rej': rejeitados,
          'escolhido': aceito.nome,
        })
        .then((value) => print(value.data['status']))
        .catchError((error) => print("Erro ao enviar: $error"));
  }

  Future<void> rejeitarDentista(List<String> rejeitados) async {
    await FirebaseFunctions.instanceFor(region: 'southamerica-east1')
        .httpsCallable("rejeitaDentista")
        .call({
          'rej': rejeitados,
          //'escolhido': aceito.nome,
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
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/fundo.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
            child: Stack(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Emergência",
                style: TextStyle(
                  fontSize: 55,
                  fontFamily: 'Chubby',
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 3
                    ..color = Colors.amber,
                  //color: Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(height: 0),
              Text(
                "Finalizada",
                style: TextStyle(
                  fontSize: 55,
                  fontFamily: 'Chubby',
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 3
                    ..color = Colors.amber,
                  //color: Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  SystemNavigator.pop();
                },
                label: const Icon(
                  Icons.logout,
                  size: 30,
                ),
                icon: const Text(
                  "Sair",
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'AvenirNextLTPro-BoldCn',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.amber,
                  onPrimary: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.blue, width: 0),
                  ),
                ),
              ),
            ],
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Emergência",
                style: TextStyle(
                  fontSize: 55,
                  fontFamily: 'Chubby',
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 0),
              Text(
                "Finalizada",
                style: TextStyle(
                  fontSize: 55,
                  fontFamily: 'Chubby',
                  color: Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(height: 63),
            ],
          )
        ])),
      ),
    );
  }
}

class listaDadosDentista {
  late String nome;
  late String telefone;
  late String cv;
  late String foto;

  listaDadosDentista(
      {required this.nome,
      required this.telefone,
      required this.cv,
      required this.foto});
}

pegarLocalizacao() async {
  Position posicao = await Geolocator.getCurrentPosition();
  final localizacao =
      LatLng(posicao.latitude.toDouble(), posicao.longitude.toDouble());
  return localizacao;
}

final List<String> _nomesDentista = <String>[];
final List<listaDadosDentista> _dadosDoDentista = <listaDadosDentista>[];
final List<String> _fotoDentista = <String>[];

var dentistaLigou = false;
