// import 'package:flutter_tts/flutter_tts.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import '../../services/firebase.dart';
import '../signin/signin.dart';
import '../timer/timer.dart';

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

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController min = TextEditingController();
  final TextEditingController sec = TextEditingController();

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
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              icon: Icon(Icons.logout))
        ],
        title: Text(widget.nameSeance),
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerRight,
          height: 40,
          child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Ajouter un temps de repos'),
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
                            String titre = "Repos";
                            int nbRep = 0;
                            int poids = 0;

                            var request = DBFirebase().addExo(
                                titre, nbRep, poids, totSec, widget.idSeance);

                            if (request != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  closeIconColor: Colors.white,
                                  backgroundColor: Colors.green,
                                  showCloseIcon: true,
                                  content: Text('Exercice ajouté'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  closeIconColor: Colors.white,
                                  backgroundColor: Colors.red,
                                  showCloseIcon: true,
                                  content: Text('Erreur'),
                                ),
                              );
                            }
                          },
                          child: const Text('Ajouter'),
                        ),
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
            stream: DBFirebase().getExosBySeance(
              widget.idSeance,
            ),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Column(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 60),
                    const Text('Erreur'),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              return ReorderableListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var date = snapshot.data!.docs[index].get('updatedAt');
                  var date2 = snapshot.data!.docs[index].get('createdAt');
                  // date au format jj-mm-aaaa hh:mm:ss
                  var date3 = date.toDate();
                  var date4 = date2.toDate();
                  return Container(
                    key: Key('cont$index'),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      tileColor: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      key: Key('$index'),
                      title: Text(snapshot.data!.docs[index].get('titre'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24)),
                      subtitle: Text('modifié le : ${date3.toString()}',
                          style: const TextStyle(fontSize: 12)),
                      leading: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Supprimer'),
                                content: const Text(
                                    'Voulez-vous vraiment supprimer cet exercice ?'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Annuler')),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);

                                      DBFirebase().deleteExoById(
                                          snapshot.data!.docs[index].id,
                                          widget.idSeance);
                                      setState(() {});
                                    },
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                proxyDecorator: proxyDecorator,
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex > newIndex) {
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
                        DBFirebase().changeOrder(widget.id, widget.idSeance,
                            element.id, newIndex, oldIndex);
                        final docRef = db
                            .collection(widget.id)
                            .doc(widget.idSeance)
                            .collection('exos')
                            .doc(element.id)
                            .update({"index": ind});
                      });
                    }
                    int ind = 0;
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
          currentIndex: 1,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.white,
          unselectedLabelStyle: TextStyle(color: Colors.white),
          selectedLabelStyle: TextStyle(color: Colors.blue),
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
                  ),
                ),
              );
            }
          },
          elevation: 8,
          backgroundColor: Colors.red,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.skip_previous),
              label: 'Previous',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.play_arrow,
              ),
              icon: Icon(Icons.pause),
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
