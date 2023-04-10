import 'package:muscucards/screens/seance/seance.dart';
import 'package:muscucards/screens/signin/signin.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  // init firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // function to get tu current user
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
      title: 'Musclor App',
      theme: ThemeData.dark(),
      home: FutureBuilder(
        future: _getUser(),
        builder: (context, snapshot) {
          // if current user exist : redirect into SeancePage
          // else : redirect into LoginPage
          if (snapshot.hasData) {
            return SeancePage(
              uid: snapshot.data!.uid,
            );
          } else {
            return const LoginPage(title: 'Musclor App');
          }
        },
      ),
    );
  }
}
