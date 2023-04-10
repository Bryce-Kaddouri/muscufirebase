// import 'package:flutter_tts/flutter_tts.dart';
import 'package:muscucards/services/textToSpeach.dart';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import '../../component/counterdown.dart';

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
  List<Card> list = [];
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
          // back return on FocusSeance
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

            var timer = element['timer'];
            var poids = element['poids'];
            var nbRep = element['nbRep'];

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
                    .then((value) {
                  controllerTimer.elementAt(nbTimerPrevious).start();
                });
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
