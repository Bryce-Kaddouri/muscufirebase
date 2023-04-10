import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase.dart';
import '../focus_seance/focus_seance.dart';
import '../signin/signin.dart';

class SeancePage extends StatefulWidget {
  final String uid;
  SeancePage({super.key, required this.uid});

  @override
  State<SeancePage> createState() => _SeancePageState();
}

class _SeancePageState extends State<SeancePage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> usersStream = DBFirebase().getSeancesByUserId(
      widget.uid,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                        'Etes vous sûr de vouloir vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Non'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await DBFirebase().logout().then(
                                (value) => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                ),
                              );
                        },
                        child: const Text('Oui'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        title: const Text('Liste des séances'),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: usersStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Container(
              margin: const EdgeInsets.all(20),
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data;
                  DateTime date = doc!.docs[index].get(('createdAt')).toDate();
                  String day = date.day.toString();
                  String month = date.month.toString();
                  String hour = date.hour.toString();
                  String minute = date.minute.toString();
                  String second = date.second.toString();

                  if (date.day < 10) {
                    day = '0${date.day}';
                  }
                  if (date.month < 10) {
                    month = '0${date.month}';
                  }
                  if (date.hour < 10) {
                    hour = '0${date.hour}';
                  }
                  if (date.minute < 10) {
                    minute = '0${date.minute}';
                  }
                  if (date.second < 10) {
                    second = '0${date.second}';
                  }
                  String dateFormated =
                      'Le $day-$month-${date.year} à $hour:$minute:$second';

                  return Column(
                    children: [
                      ListTile(
                        tileColor: Colors.grey[900],
                        trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Supprimer la séance'),
                                    content: const Text(
                                        'Voulez-vous vraiment supprimer cette séance ?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Annuler')),
                                      TextButton(
                                          onPressed: () {
                                            DBFirebase().deleteSeanceById(
                                                doc.docs[index].id);

                                            Navigator.pop(context);
                                            // show snackbar
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                showCloseIcon: true,
                                                closeIconColor: Colors.white,
                                                backgroundColor: Colors.green,
                                                content: Text(
                                                    'La séance a été supprimée'),
                                              ),
                                            );
                                          },
                                          child: const Text('Supprimer')),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.delete, color: Colors.red)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FocusSeance(
                                id: widget.uid,
                                idSeance: doc.docs[index].id,
                                nameSeance: doc.docs[index].get(('titre')),
                              ),
                            ),
                          );
                        },
                        title: Text(
                          doc.docs[index].get(('titre')),
                        ),
                        subtitle: Text(dateFormated),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
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
                title: const Text('Ajouter une séance'),
                content: Container(
                  height: 200,
                  child: Form(
                    child: Column(
                      children: [
                        const Text('Saisir le nom de la séance'),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
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
                      child: const Text('Annuler')),
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        DBFirebase().addSeance(
                          _nameController.text,
                        );
                      },
                      child: const Text('Ajouter'))
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
