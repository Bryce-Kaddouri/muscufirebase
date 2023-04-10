import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:muscucards/services/textToSpeach.dart';

import '../start_seance.dart/start_seance.dart';

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
        title: const Text('Compte à rebourd'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 120,
            child: Center(
              child: Text(
                'La séance commence dans :',
                style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Center(
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
              textStyle: const TextStyle(
                  fontSize: 33.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              textFormat: CountdownTextFormat.S,
              isReverse: true,
              isReverseAnimation: false,
              isTimerTextShown: true,
              autoStart: true,
              onStart: () {
                debugPrint('Countdown Started');
                TextToSpeach().speak('5... 4... 3... 2... 1...');
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
        ],
      ),
    );
  }
}
