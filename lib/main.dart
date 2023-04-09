import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_tts/flutter_tts.dart';
import 'dart:ui';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  Future _getUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      return user;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: FutureBuilder(
        future: _getUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage(
              uid: snapshot.data!.uid,
            );
          } else {
            return MyHomePage(title: 'Flutter Demo Home Page');
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // global key for the form
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    // controller for email field
    final TextEditingController _emailController = TextEditingController();
    // controller for password field
    final TextEditingController _passwordController = TextEditingController();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Container(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .signInWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text);
                        print(userCredential);

                        if (userCredential.user != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage(
                                        uid: userCredential.user!.uid,
                                      )));
                        }
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          print('The password provided is too weak.');
                        } else if (e.code == 'email-already-in-use') {
                          print('The account already exists for that email.');
                        }
                      } catch (e) {
                        print(e);
                      }
                    }
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ));
  }
}

class HomePage extends StatefulWidget {
  final String uid;
  HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // global key for the add form
  final GlobalKey<FormState> _addFormKey = GlobalKey<FormState>();
  // controller for name field
  final TextEditingController _nameController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _usersStream =
        FirebaseFirestore.instance.collection(widget.uid).snapshots();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MyHomePage(title: 'Flutter Demo')));
              },
              icon: Icon(Icons.logout))
        ],
        title: Text(user!.email!),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: _usersStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data;

                // var test = doc!.docs[index].data();

                // print(test[]);
                // print(doc.docs[index].id);
                return ListTile(
                  onTap: () {
                    print(doc!.docs[index].get(('titre')));
                    print('--');
                    print(snapshot.data.toString());
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FocusSeance(
                                  id: widget.uid,
                                  idSeance: doc.docs[index].id,
                                  nameSeance: doc!.docs[index].get(('titre')),
                                )));
                  },
                  title: Text(doc!.docs[index].get(('titre'))),
                  subtitle: Text('tet'),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Ajouter une séance'),
                content: Container(
                  height: 200,
                  child: Form(
                    child: Column(
                      children: [
                        Text('Saisir le nom de la séance'),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Titre',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Annuler')),
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        var db = FirebaseFirestore.instance;
                        // get nb documents qui commence par seance
                        // ajouter 1
                        // ajouter le document

                        var t = await db
                            .collection("5dMzBRtLwNeCqScwT1yVuz0FGuG2")
                            .add({
                          'titre': _nameController.text,
                          'createdAt': Timestamp.now(),
                          'updatedAt': Timestamp.now(),
                        });

                        print('---------------------------------');
                        print(t.toString());

                        int nb = 0;
                        setState(() {});
                      },
                      child: Text('Ajouter'))
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class FocusSeance extends StatefulWidget {
  final String id;
  final String idSeance;
  final String nameSeance;

  FocusSeance({
    super.key,
    required this.id,
    required this.idSeance,
    required this.nameSeance,
  });

  @override
  State<FocusSeance> createState() => _FocusSeanceState();
}

class _FocusSeanceState extends State<FocusSeance> {
  // global key for the add form
  final GlobalKey<FormState> _addFormKey = GlobalKey<FormState>();
  // controller for name field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nbRepController = TextEditingController();
  final TextEditingController _poidsController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;

  Future<bool> changeOrder(String idUser, String idSeance, String idExo,
      int newIndex, int oldIndex) async {
    var db = FirebaseFirestore.instance;

    try {
      var docRef =
          // db.collection(idUser).doc(idSeance).collection('exos').snapshots();
          db
              .collection(idUser)
              .doc(idSeance)
              .collection('exos')
              .doc(idExo)
              .update({'index': newIndex});
      var docRef1 =
          // db.collection(idUser).doc(idSeance).collection('exos').snapshots();
          db
              .collection(idUser)
              .doc(idSeance)
              .collection('exos')
              .doc(idExo)
              .update({'index': oldIndex});
      return true;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      return false;
      // if (e.code == 'weak-password') {
      //   print('The password provided is too weak.');
      // } else if (e.code == 'email-already-in-use') {
      //   print('The account already exists for that email.');
      // }
    } catch (e) {
      print(e);
      return false;
    }
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController min = TextEditingController();
  final TextEditingController sec = TextEditingController();

  // function to get a document from firestore collection by id
  Stream<QuerySnapshot> getDocumentById(String idSeance, String idUser) {
    var db = FirebaseFirestore.instance;
    final docRef =
        // db.collection(idUser).doc(idSeance).collection('exos').snapshots();
        db
            .collection(idUser)
            .doc(idSeance)
            .collection('exos')
            .orderBy('index')
            .snapshots();

    return docRef;
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyHomePage(title: 'exo Demo')));
              },
              icon: Icon(Icons.logout))
        ],
        title: Text(widget.nameSeance),
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerRight,
          height: 40,
          child: ElevatedButton.icon(
              onPressed: () {
                // global key

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Ajouter un temps de repos'),
                      content: Container(
                        height: 200,
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: min,
                              ),
                              TextFormField(
                                controller: sec,
                              )
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Annuler')),
                        TextButton(
                            onPressed: () async {
                              int minS = int.parse(min.text);
                              int secS = int.parse(sec.text);
                              int totSec = 60 * minS + secS;
                              Navigator.pop(context);
                              var db = FirebaseFirestore.instance;
                              String titre = "Repos";
                              int nbRep = 0;
                              int poids = 0;

                              // recup exos
                              var exos = await db
                                  .collection(user!.uid)
                                  .doc(widget.idSeance)
                                  .collection('exos')
                                  .get();

                              print('titre: ');
                              print(titre);
                              print('nbRep: ');
                              print(nbRep);
                              print('poids: ');
                              print(poids);

                              var t = await db
                                  .collection(user!.uid)
                                  .doc(widget.idSeance)
                                  .collection('exos')
                                  .add({
                                'titre': titre,
                                'index': exos.size + 1,
                                'nbRep': nbRep,
                                'poids': poids,
                                'timer': totSec,
                                'createdAt': Timestamp.now(),
                                'updatedAt': Timestamp.now(),
                              });

                              print('---------------------------------');
                              print(t.toString());

                              int nb = 0;
                              // setState(() {});
                            },
                            child: Text('Ajouter'))
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.add),
              label: Text('Repos')),
        ),
        Container(
          height: MediaQuery.of(context).size.height - 160,
          child: StreamBuilder<QuerySnapshot>(
            stream: getDocumentById(widget.idSeance, user!.uid),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }
              print('exos: ');
              print(snapshot.data!.docs.length);

              return ReorderableListView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                proxyDecorator: proxyDecorator,
                children: <Widget>[
                  for (int index = 0;
                      index < snapshot.data!.docs.length;
                      index += 1)
                    ListTile(
                      key: Key('$index'),
                      title: Text(snapshot.data!.docs[index].get('titre')),
                    ),
                ],
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    // if (oldIndex < newIndex) {
                    //   newIndex -= 1;
                    // }
                    print('old');
                    print(oldIndex);
                    print('new');

                    print(newIndex);

                    if (oldIndex > newIndex) {
                      print('montee');

                      var test =
                          snapshot.data!.docs.getRange(newIndex, oldIndex);
                      test.forEach((element) {
                        var db = FirebaseFirestore.instance;
                        int ind = element.get('index') + 1;
                        final docRef = db
                            .collection(widget.id)
                            .doc(widget.idSeance)
                            .collection('exos')
                            .doc(element.id)
                            .update({"index": ind});

                        print('--------');
                        print('index :');
                        print(element.get('index'));
                        print(element.id);
                        print('--------');
                      });
                    } else if (newIndex == snapshot.data!.docs.length) {
                      var test = snapshot.data!.docs.getRange(0, newIndex);
                      var db = FirebaseFirestore.instance;
                      final docRef = db
                          .collection(widget.id)
                          .doc(widget.idSeance)
                          .collection('exos')
                          .doc(snapshot.data!.docs[oldIndex].id)
                          .update({"index": newIndex});

                      test.forEach((element) {
                        int ind = element.get('index') - 1;
                        final docRef = db
                            .collection(widget.id)
                            .doc(widget.idSeance)
                            .collection('exos')
                            .doc(element.id)
                            .update({"index": ind});
                      });
                    } else if (newIndex == 0) {
                      print(newIndex);
                      var test = snapshot.data!.docs
                          .getRange(1, snapshot.data!.docs.length);
                      var db = FirebaseFirestore.instance;
                      final docRef = db
                          .collection(widget.id)
                          .doc(widget.idSeance)
                          .collection('exos')
                          .doc(snapshot.data!.docs[oldIndex].id)
                          .update({"index": newIndex});

                      test.forEach((element) {
                        int ind = element.get('index') + 1;
                        final docRef = db
                            .collection(widget.id)
                            .doc(widget.idSeance)
                            .collection('exos')
                            .doc(element.id)
                            .update({"index": ind});
                      });
                    } else {
                      print('descente');
                      var test =
                          snapshot.data!.docs.getRange(oldIndex, newIndex);
                      test.forEach((element) {
                        var db = FirebaseFirestore.instance;
                        int ind = element.get('index') - 1;
                        final docRef = db
                            .collection(widget.id)
                            .doc(widget.idSeance)
                            .collection('exos')
                            .doc(element.id)
                            .update({"index": ind});
                      });
                    }
                    int ind = 0;
                    // while (ind < )
                    print(snapshot.data!.docs[oldIndex].id);
                    changeOrder(widget.id, widget.idSeance,
                        snapshot.data!.docs[oldIndex].id, newIndex, oldIndex);

                    // final int item = _items.removeAt(oldIndex);
                    // _items.insert(newIndex, item);
                  });
                },
              );
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Ajouter un exercice'),
                content: Container(
                  height: 200,
                  child: Form(
                    child: Column(
                      children: [
                        Text('Saisir le nom de l\'exercice'),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Titre',
                          ),
                        ),
                        TextFormField(
                          controller: _nbRepController,
                          decoration: InputDecoration(
                            labelText: 'nb Rep',
                          ),
                        ),
                        TextFormField(
                          controller: _poidsController,
                          decoration: InputDecoration(
                            labelText: 'poids',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Annuler')),
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        var db = FirebaseFirestore.instance;
                        String titre = _nameController.text;
                        int nbRep = int.parse(_nbRepController.text);
                        int poids = int.parse(_poidsController.text);

                        // recup exos
                        var exos = await db
                            .collection(user!.uid)
                            .doc(widget.idSeance)
                            .collection('exos')
                            .get();

                        print('titre: ');
                        print(titre);
                        print('nbRep: ');
                        print(nbRep);
                        print('poids: ');
                        print(poids);

                        var t = await db
                            .collection(user!.uid)
                            .doc(widget.idSeance)
                            .collection('exos')
                            .add({
                          'titre': titre,
                          'index': exos.size + 1,
                          'nbRep': nbRep,
                          'poids': poids,
                          'timer': 0,
                          'createdAt': Timestamp.now(),
                          'updatedAt': Timestamp.now(),
                        });

                        print('---------------------------------');
                        print(t.toString());

                        int nb = 0;
                        // setState(() {});
                      },
                      child: Text('Ajouter'))
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: Colors.amber[800],
          onTap: (value) {
            final int _duration = 10;
            final CountDownController _controller = CountDownController();
            print(value);
            if (value == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Timer(
                          timer: 5,
                          idUser: widget.id,
                          idSeance: widget.idSeance,
                        )),
              );
            }
          },
          elevation: 8,
          backgroundColor: Colors.red,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.skip_previous),
              label: 'Previous',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.pause),
              icon: Icon(Icons.play_arrow),
              label: 'Play',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.skip_next),
              label: 'Next',
            ),
          ]),
    );
  }
}

enum TtsState { playing, stopped, paused, continued }

class StartSeanceScreen extends StatefulWidget {
  String idSeance;
  String idUser;
  StartSeanceScreen({super.key, required this.idSeance, required this.idUser});

  @override
  State<StartSeanceScreen> createState() => _StartSeanceScreenState();
}

class _StartSeanceScreenState extends State<StartSeanceScreen> {
  String? language;
  String? engine;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.8;
  bool isCurrentLanguageInstalled = false;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  FlutterTts flutterTts = FlutterTts();

  Stream<QuerySnapshot> getDocumentById(String idSeance, String idUser) {
    var db = FirebaseFirestore.instance;
    final docRef = db
        .collection(idUser)
        .doc(idSeance)
        .collection('exos')
        .orderBy('index')
        .snapshots();

    return docRef;
  }

  Future speak(String text) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    await flutterTts.speak(text);
  }

  final int _duration = 10;

  int currentCard = 0;
  List<CountDownController> controllerTimer = [];
  var nextPage = 1;
  int nb = 0;
  List<Card> list = [];
  PageController controller = PageController();

  initTts() {
    flutterTts = FlutterTts();

    // _setAwaitOptions();

    if (isAndroid) {
      // _getDefaultEngine();
      // _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    if (isAndroid) {
      flutterTts.setInitHandler(() {
        setState(() {
          print("TTS Initialized");
        });
      });
    }

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  @override
  initState() {
    super.initState();

    // speak();
    // initTts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Seance'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getDocumentById(widget.idSeance, widget.idUser),
        builder: (context, snapshot) {
          print('datas start:');
          print(snapshot.data);
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          var indexList = 0;

          List tets =
              snapshot.data!.docs.toList().map((e) => e.data()).toList();
          print('test size');
          print(tets.length);

          tets.forEach((element) {
            print('test forEach');
            print(element);
            var titre = element['titre'];
            // var id = element['id'];

            var timer = element['timer'];
            var poids = element['poids'];
            var nbRep = element['nbRep'];
            // card de fin avec un gif animé de trophe

            late Card card;

            if (timer == 0) {
              card = Card(
                color: Colors.white,
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.blue,
                        width: 300,
                        child: Text(
                          titre,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontSize: 32),
                        ),
                      ),
                      FlutterLogo(size: 300),
                      Text(
                        '$nbRep répétitions à $poids KG',
                        style: TextStyle(color: Colors.black, fontSize: 24),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              controllerTimer.add(CountDownController());

              card = Card(
                color: Colors.white,
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        color: Colors.blue,
                        width: 300,
                        child: Text(
                          titre,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                      Container(
                        width: 300,
                        height: 300,
                        child: CounterDown(
                            onComplete: () {
                              int size = controllerTimer.length;
                              print('size');
                              print(nextPage);
                              if (nextPage < size - 1) {
                                controller.nextPage(
                                    duration: Duration(seconds: 1),
                                    curve: Curves.ease);
                                nextPage++;
                              } else {
                                print('last');
                                // speak(
                                //     'Bravo ! Vous avec terminé cette séance !');
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Bravo'),
                                        content: Text(
                                            'Vous avez terminé votre séance'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: Text('Retour'))
                                        ],
                                      );
                                    });
                              }
                              // controller.nextPage(
                              //     duration: Duration(seconds: 1),
                              //     curve: Curves.ease);
                            },
                            idCard: 1,
                            currentPage: currentCard,
                            autoStart: false,
                            controller: controllerTimer[indexList],
                            idSeance: '',
                            idUser: widget.idUser,
                            timer: timer),
                      ),
                    ],
                  ),
                ),
              );

              // nb++;
              indexList++;
            }
            list.add(card);
          });

          // ListWheelScrollView itemExtent: 500,

          return StackedCardCarousel(
            type: StackedCardCarouselType.cardsStack,
            onPageChanged: (pageIndex) {
              int nbTimerPrevious = 0;
              var docs = snapshot.data!.docs;

              for (var i = 0; i < pageIndex; i++) {
                if (docs.elementAt(i)['timer'] != 0) {
                  // controllerTimer.elementAt(i).pause();
                  nbTimerPrevious++;
                }
              }

              if (docs.elementAt(pageIndex)['timer'] != 0) {
                speak('${docs.elementAt(pageIndex)['timer']} secondes de repos')
                    .then((value) {
                  controllerTimer.elementAt(nbTimerPrevious).start();
                });
                print('nbTimerPrevious');

                print(nbTimerPrevious);
              } else {
                speak(
                    '${docs.elementAt(pageIndex)['titre']}, ${docs.elementAt(pageIndex)['nbRep']} répétitions à ${docs.elementAt(pageIndex)['poids']} Kilo');
                print('nbTimerPrevious');
                print(nbTimerPrevious);
                controllerTimer.elementAt(nbTimerPrevious).pause();
              }

              print('nbTimerPrevious');
              print(nbTimerPrevious);

              currentCard = pageIndex;
            },
            pageController: controller,
            items: list,
          );
        },
      ),

      //
    );
  }
}

class Timer extends StatefulWidget {
  int timer;
  String idSeance;
  String idUser;
  Timer(
      {super.key,
      required this.timer,
      required this.idSeance,
      required this.idUser});

  @override
  State<Timer> createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('timer'),
      ),
      body: Center(
        child: CircularCountDownTimer(
          duration: widget.timer,
          initialDuration: 0,
          controller: CountDownController(),
          width: MediaQuery.of(context).size.width / 2,
          height: MediaQuery.of(context).size.height / 2,
          ringColor: Colors.grey[300]!,
          ringGradient: null,
          fillColor: Colors.purpleAccent[100]!,
          fillGradient: null,
          backgroundColor: Colors.purple[500],
          backgroundGradient: null,
          strokeWidth: 20.0,
          strokeCap: StrokeCap.round,
          textStyle: TextStyle(
              fontSize: 33.0, color: Colors.white, fontWeight: FontWeight.bold),
          textFormat: CountdownTextFormat.S,
          isReverse: true,
          isReverseAnimation: false,
          isTimerTextShown: true,
          autoStart: true,
          onStart: () {
            debugPrint('Countdown Started');
          },
          onComplete: () {
            debugPrint('Countdown Ended');
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StartSeanceScreen(
                      idSeance: widget.idSeance, idUser: widget.idUser)),
            );
          },
          onChange: (String timeStamp) {
            debugPrint('Countdown Changed $timeStamp');
          },
          timeFormatterFunction: (defaultFormatterFunction, duration) {
            if (duration.inSeconds == 0) {
              return "Lets Go!";
            } else {
              return Function.apply(defaultFormatterFunction, [duration]);
            }
          },
        ),
      ),
    );
  }
}

class CounterDown extends StatefulWidget {
  Function onComplete;
  bool autoStart;
  CountDownController controller;
  int timer;
  int idCard;
  String idSeance;
  String idUser;
  int currentPage;
  CounterDown(
      {super.key,
      required this.idCard,
      required this.timer,
      required this.idSeance,
      required this.idUser,
      required this.controller,
      required this.autoStart,
      required this.currentPage,
      required this.onComplete});

  @override
  State<CounterDown> createState() => _CounterDownState();
}

class _CounterDownState extends State<CounterDown> {
  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      widget.controller.start();
    }
    // widget.controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularCountDownTimer(
        duration: widget.timer,
        initialDuration: 0,
        controller: widget.controller,
        width: MediaQuery.of(context).size.width / 2,
        height: MediaQuery.of(context).size.height / 2,
        ringColor: Colors.grey[300]!,
        ringGradient: null,
        fillColor: Colors.purpleAccent[100]!,
        fillGradient: null,
        backgroundColor: Colors.purple[500],
        backgroundGradient: null,
        strokeWidth: 20.0,
        strokeCap: StrokeCap.round,
        textStyle: TextStyle(
            fontSize: 33.0, color: Colors.white, fontWeight: FontWeight.bold),
        textFormat: CountdownTextFormat.S,
        isReverse: true,
        isReverseAnimation: false,
        isTimerTextShown: true,
        autoStart: widget.autoStart,
        onStart: () {
          debugPrint('Countdown Started');
        },
        onComplete: () {
          widget.onComplete();
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => StartSeanceScreen(
          //           idSeance: widget.idSeance, idUser: widget.idUser)),
          // );
        },
        onChange: (String timeStamp) {
          debugPrint('Countdown Changed $timeStamp');
        },
        timeFormatterFunction: (defaultFormatterFunction, duration) {
          if (duration.inSeconds == 0) {
            return "Lets Go!";
          } else {
            return Function.apply(defaultFormatterFunction, [duration]);
          }
        },
      ),
    );
  }
}
