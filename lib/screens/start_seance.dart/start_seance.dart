// import 'package:flutter_tts/flutter_tts.dart';
import 'package:muscucards/screens/start_seance.dart/repos_card.dart';
import 'package:muscucards/services/textToSpeach.dart';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import 'components/classical_card.dart';

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

  int currentCard = 0;
  List<CountDownController> controllerTimer = [];
  var nextPage = 1;
  int nb = 0;
  List<Widget> list = [];
  PageController controller = PageController();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Start Seance'),
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios))),
      body: StreamBuilder<QuerySnapshot>(
        stream: getDocumentById(widget.idSeance, widget.idUser),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          var indexList = 0;

          List tets =
              snapshot.data!.docs.toList().map((e) => e.data()).toList();

          if (tets.elementAt(0)['timer'] == 0) {
            TextToSpeach().speak(
                '${tets.elementAt(0)['titre']}, ${tets.elementAt(0)['nbRep']} répétitions à ${tets.elementAt(0)['poids']} Kilo');
          } else {
            TextToSpeach().speak(
                '${tets.elementAt(0)['titre']} de ${tets.elementAt(0)['timer']} secondes');
          }
          tets.forEach(
            (element) {
              var titre = element['titre'];
              var timer = element['timer'];
              var poids = element['poids'];
              var nbRep = element['nbRep'];

              late Widget card;

              if (timer == 0) {
                card = ClassicalCard(
                  titre: titre,
                  nbRep: nbRep,
                  poids: poids,
                );
              } else {
                controllerTimer.add(CountDownController());

                card = ReposCard(
                    titre: titre,
                    controller: controllerTimer[indexList],
                    onComplete: () {
                      int size = controllerTimer.length;

                      if (nextPage < size - 1) {
                        controller.nextPage(
                            duration: Duration(seconds: 1), curve: Curves.ease);
                        nextPage++;
                      } else {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Bravo'),
                              content: Text('Vous avez terminé votre séance'),
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
                          },
                        );
                      }
                    },
                    currentCard: currentCard,
                    timer: timer,
                    idUser: widget.idUser);

                indexList++;
              }
              list.add(card);
            },
          );

          return StackedCardCarousel(
            type: StackedCardCarouselType.cardsStack,
            onPageChanged: (pageIndex) {
              int nbTimerPrevious = 0;
              var docs = snapshot.data!.docs;

              for (var i = 0; i < pageIndex; i++) {
                if (docs.elementAt(i)['timer'] != 0) {
                  nbTimerPrevious++;
                }
              }

              if (docs.elementAt(pageIndex)['timer'] != 0) {
                TextToSpeach()
                    .speak(
                        '${docs.elementAt(pageIndex)['timer']} secondes de repos')
                    .then(
                  (value) {
                    controllerTimer.elementAt(nbTimerPrevious).start();
                  },
                );
                print('nbTimerPrevious');

                print(nbTimerPrevious);
              } else {
                TextToSpeach().speak(
                    '${docs.elementAt(pageIndex)['titre']}, ${docs.elementAt(pageIndex)['nbRep']} répétitions à ${docs.elementAt(pageIndex)['poids']} Kilo');
                print('nbTimerPrevious');
                print(nbTimerPrevious);
                controllerTimer.elementAt(nbTimerPrevious).pause();
              }

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
