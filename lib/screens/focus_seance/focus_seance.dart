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
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
            icon: const Icon(Icons.logout),
          )
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      // verif int compris entre 0 et 59
                                      return 'Veuillez renseigner ce champ';
                                    } else {
                                      // verif que c'est un int
                                      try {
                                        int.parse(value);
                                        if (int.parse(value) > 59 ||
                                            int.parse(value) < 0) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                iconColor: Colors.red,
                                                icon: const Icon(
                                                  Icons.error,
                                                  size: 100,
                                                ),
                                                title: const Text('Erreur'),
                                                content: const Text(
                                                    'Veuillez renseigner un nombre entre 0 et 59'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Ok'),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                          return '';
                                        } else {
                                          return null;
                                        }
                                      } catch (e) {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              iconColor: Colors.red,
                                              icon: const Icon(
                                                Icons.error,
                                                size: 100,
                                              ),
                                              title: const Text('Erreur'),
                                              content: const Text(
                                                  'Veuillez renseigner un nombre'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Ok'),
                                                )
                                              ],
                                            );
                                          },
                                        );
                                        return '';
                                      }
                                    }
                                  },
                                  controller: min,
                                  decoration: const InputDecoration(
                                    labelText: 'Minutes',
                                    border: OutlineInputBorder(),
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Text(' : '),
                              Container(
                                width: 100,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      // verif int compris entre 0 et 59
                                      return 'Veuillez renseigner ce champ';
                                    } else {
                                      // verif que c'est un int
                                      try {
                                        int.parse(value);
                                        if (int.parse(value) > 59 ||
                                            int.parse(value) < 0) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                iconColor: Colors.red,
                                                icon: const Icon(
                                                  Icons.error,
                                                  size: 100,
                                                ),
                                                title: const Text('Erreur'),
                                                content: const Text(
                                                    'Veuillez renseigner un nombre entre 0 et 59'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Ok'),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                          return '';
                                        } else {
                                          return null;
                                        }
                                      } catch (e) {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              iconColor: Colors.red,
                                              icon: const Icon(
                                                Icons.error,
                                                size: 100,
                                              ),
                                              title: const Text('Erreur'),
                                              content: const Text(
                                                  'Veuillez renseigner un nombre'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Ok'),
                                                )
                                              ],
                                            );
                                          },
                                        );
                                        return '';
                                      }
                                    }
                                  },
                                  controller: sec,
                                  decoration: const InputDecoration(
                                    fillColor: Colors.white,
                                    labelText: 'Secondes',
                                    border: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
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
                            if (formKey.currentState!.validate()) {
                              if (int.parse(min.text) == 0 &&
                                  int.parse(sec.text) == 0) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      iconColor: Colors.red,
                                      icon: const Icon(
                                        Icons.error,
                                        size: 100,
                                      ),
                                      title: const Text('Erreur'),
                                      content: const Text(
                                          'Veuillez renseigner un temps de repos supérieur à 0'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Ok'),
                                        )
                                      ],
                                    );
                                  },
                                );
                              } else {
                                int minS = int.parse(min.text);
                                int secS = int.parse(sec.text);
                                int totSec = 60 * minS + secS;
                                Navigator.pop(context);
                                String titre = "Repos";
                                int nbRep = 0;
                                int poids = 0;

                                var request = DBFirebase().addExo(titre, nbRep,
                                    poids, totSec, widget.idSeance);

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
                              }
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
                  var getUpdate = snapshot.data!.docs[index].get('updatedAt');
                  var getCreate = snapshot.data!.docs[index].get('createdAt');
                  var dateUpdate = getUpdate.toDate();
                  var dateCreate = getCreate.toDate();
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
                      subtitle: Text(
                        'modifié le : ${dateUpdate.toString()}',
                        style: const TextStyle(fontSize: 12),
                      ),
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
                onReorder: (int from, int to) {
                  bool fromIsGreat = from > to ? true : false;

                  if (fromIsGreat) {
                    for (var i = to; i < snapshot.data!.docs.length; i++) {
                      if (i == to) {
                        String idExo = snapshot.data!.docs[from].id;
                        DBFirebase().updateIndexExo(
                            user!.uid, widget.idSeance, idExo, i);
                      }
                      if (i != from) {
                        String idExo = snapshot.data!.docs[i].id;
                        DBFirebase().updateIndexExo(
                            user!.uid, widget.idSeance, idExo, i + 1);
                      }
                    }
                    setState(() {});
                  } else {
                    for (var i = 0; i < to; i++) {
                      if (i == from) {
                        String idExo = snapshot.data!.docs[from].id;
                        DBFirebase().updateIndexExo(
                            user!.uid, widget.idSeance, idExo, to - 1);
                      }
                      if (i != from) {
                        String idExo = snapshot.data!.docs[i].id;

                        DBFirebase().updateIndexExo(
                            user!.uid, widget.idSeance, idExo, i);
                      }
                    }
                  }
                },
              );
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          RegExp regexInt = RegExp(r'^[0-9]+$');
          RegExp regexString = RegExp(r'^[a-zA-Z]+$');

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Ajouter un exercice'),
                content: Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: Form(
                    key: _addFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Saisir le nom de l\'exercice'),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir un nom';
                            } else {
                              if (!regexString.hasMatch(value)) {
                                return 'Veuillez saisir un nom valide';
                              }
                            }
                            return null;
                          },
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Titre',
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir un nombre de répétitions';
                            } else {
                              if (!regexInt.hasMatch(value)) {
                                return 'Veuillez saisir un nombre de répétitions valide';
                              } else {
                                if (int.parse(value) <= 0) {
                                  return 'Veuillez saisir un nombre de répétitions valide';
                                }
                              }
                            }
                            return null;
                          },
                          controller: _nbRepController,
                          decoration: InputDecoration(
                            labelText: 'nb Rep',
                          ),
                        ),
                        TextFormField(
                          controller: _poidsController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir un poids';
                            } else {
                              if (!regexInt.hasMatch(value)) {
                                return 'Veuillez saisir un poids valide';
                              } else {
                                if (int.parse(value) <= 0) {
                                  return 'Veuillez saisir un poids valide';
                                }
                              }
                            }
                            return null;
                          },
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
                      if (_addFormKey.currentState!.validate()) {
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
                            .add(
                          {
                            'titre': titre,
                            'index': exos.size + 1,
                            'nbRep': nbRep,
                            'poids': poids,
                            'timer': 0,
                            'createdAt': Timestamp.now(),
                            'updatedAt': Timestamp.now(),
                          },
                        );
                      }
                    },
                    child: Text('Ajouter'),
                  )
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
