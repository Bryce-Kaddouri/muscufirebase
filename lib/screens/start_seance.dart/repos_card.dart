import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import '../../component/counterdown.dart';

class ReposCard extends StatelessWidget {
  String titre;
  CountDownController controller;
  Function onComplete;
  int currentCard;
  int timer;
  String idUser;

  ReposCard({
    super.key,
    required this.titre,
    required this.controller,
    required this.onComplete,
    required this.currentCard,
    required this.timer,
    required this.idUser,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  onComplete();
                  // int size = controllerTimer.length;
                  // print('size');
                  // print(nextPage);
                  // if (nextPage < size - 1) {
                  //   controller.nextPage(
                  //       duration: Duration(seconds: 1), curve: Curves.ease);
                  //   nextPage++;
                  // } else {
                  //   print('last');
                  //   // speak(
                  //   //     'Bravo ! Vous avec terminé cette séance !');
                  //   showDialog(
                  //       barrierDismissible: false,
                  //       context: context,
                  //       builder: (context) {
                  //         return AlertDialog(
                  //           title: Text('Bravo'),
                  //           content: Text('Vous avez terminé votre séance'),
                  //           actions: [
                  //             TextButton(
                  //                 onPressed: () {
                  //                   Navigator.pop(context);
                  //                   Navigator.pop(context);
                  //                   Navigator.pop(context);
                  //                 },
                  //                 child: Text('Retour'))
                  //           ],
                  //         );
                  //       });
                  // }
                },
                idCard: 1,
                currentPage: currentCard,
                autoStart: false,
                controller: controller,
                // controllerTimer[indexList],
                idSeance: '',
                idUser: idUser,
                timer: timer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
