import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:muscucards/services/firebase.dart';

import '../../focus_seance/focus_seance.dart';

class Body extends StatelessWidget {
  AsyncSnapshot<QuerySnapshot> snapshot;
  String uid;
  Body({super.key, required this.snapshot, required this.uid});

  @override
  Widget build(BuildContext context) {
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
                                    DBFirebase()
                                        .deleteSeanceById(doc.docs[index].id);

                                    Navigator.pop(context);
                                    // show snackbar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        showCloseIcon: true,
                                        closeIconColor: Colors.white,
                                        backgroundColor: Colors.green,
                                        content:
                                            Text('La séance a été supprimée'),
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
                        nbMax: doc.docs.length,
                        currentIndex: index,
                        id: uid,
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
  }
}
