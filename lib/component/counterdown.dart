import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:muscucards/services/textToSpeach.dart';

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
          TextToSpeach().speak('Repos terminé').whenComplete(() {
            widget.onComplete();
          });

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
