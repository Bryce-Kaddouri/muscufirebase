import 'dart:convert';
import 'dart:html';
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
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
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
  final TextEditingController _timerController = TextEditingController();

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
      body: StreamBuilder<QuerySnapshot>(
        stream: getDocumentById(widget.idSeance, user!.uid),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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

                  var test = snapshot.data!.docs.getRange(newIndex, oldIndex);
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
                  var test = snapshot.data!.docs.getRange(oldIndex, newIndex);
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
                        TextFormField(
                          controller: _timerController,
                          decoration: InputDecoration(
                            labelText: 'timer',
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
                        int timer = int.parse(_timerController.text);

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
                          'timer': timer,
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

class StartSeanceScreen extends StatefulWidget {
  String idSeance;
  String idUser;
  StartSeanceScreen({super.key, required this.idSeance, required this.idUser});

  @override
  State<StartSeanceScreen> createState() => _StartSeanceScreenState();
}

class _StartSeanceScreenState extends State<StartSeanceScreen> {
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

  final int _duration = 10;
  final CountDownController _controller = CountDownController();

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

          List<Card> list = [];

          for (var i = 0; i < snapshot.data!.size; i++) {
            print(snapshot.data!.docs.elementAt(i).data());
            Card card = Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 250,
                      height: 250,
                      child: Text('test'),
                    ),
                    Text(
                      'test',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    OutlinedButton(
                      child: const Text("Learn more"),
                      onPressed: () => print("Button was tapped"),
                    ),
                  ],
                ),
              ),
            );
            list.add(card);
          }

          PageController controller = PageController();
          // ListWheelScrollView itemExtent: 500,

          return StackedCardCarousel(
            onPageChanged: (pageIndex) {
              controller.jumpToPage(pageIndex);
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
  String idSeance;
  String idUser;
  Timer({super.key, required this.idSeance, required this.idUser});

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
          duration: 5,
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
