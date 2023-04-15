import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muscucards/screens/signin/signin.dart';

import '../../../services/firebase.dart';

class FormSignup extends StatefulWidget {
  GlobalKey<FormState> formKey;
  TextEditingController emailController;
  TextEditingController passwordController;

  FormSignup(
      {super.key,
      required this.formKey,
      required this.emailController,
      required this.passwordController});

  @override
  State<FormSignup> createState() => _FormSignupState();
}

class _FormSignupState extends State<FormSignup> {
  // regex for email
  RegExp regEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  RegExp regPassword = RegExp(
      r'^(?=.*?[A-Z].*?[A-Z])(?=.*?[0-9].*?[0-9])(?=.*?[!@#$%^&*()].*?[!@#$%^&*()])[A-Za-z0-9!@#$%^&*()]{10,}$');

//       Explication de cette expression régulière :

// ^ - Début de la chaîne
// (?=.*?[A-Z].*?[A-Z]) - Recherchez deux occurrences de lettres majuscules
// (?=.*?[0-9].*?[0-9]) - Recherchez deux occurrences de chiffres
// (?=.*?[!@#$%^&*()].*?[!@#$%^&*()]) - Recherchez deux occurrences de caractères spéciaux (sélectionnés ici comme étant : !@#$%^&*())
// [A-Za-z0-9!@#$%^&*()]{10,} - Correspond à une chaîne de 10 caractères minimum composée de caractères alphanumériques et de caractères spéciaux spécifiés
// $ - Fin de la chaîne

  bool isGreat10 = false;
  bool is2specialCarac = false;
  bool is2Maj = false;
  bool is2Chiffre = false;

  RegExp reg1 = RegExp(r'(?=.*?[A-Z].*?[A-Z])');
  RegExp reg2 = RegExp(r'(?=.*?[0-9].*?[0-9])');
  RegExp reg3 = RegExp(r'(?=.*?[!@#$%^&*()].*?[!@#$%^&*()])');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: widget.formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Création d\'un compte', style: TextStyle(fontSize: 40)),
            const SizedBox(
              height: 60,
            ),
            TextFormField(
              controller: widget.emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusColor: Colors.blue,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                } else if (!regEmail.hasMatch(value)) {
                  return 'Email non valide';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  isGreat10 = value.length >= 10 ? true : false;
                  is2Maj = reg1.hasMatch(value);
                  is2Chiffre = reg2.hasMatch(value);
                  is2specialCarac = reg3.hasMatch(value);
                });
                print('2 maj : ${reg1.hasMatch(value)}');
                print('2 chiffre : ${reg2.hasMatch(value)}');
                print('2 speciaux : ${reg3.hasMatch(value)}');
                print('-------------------------');
              },
              controller: widget.passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                } else if (!regPassword.hasMatch(value)) {
                  return 'Mot de passe non valide';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusColor: Colors.blue,
              ),
            ),
            Container(
              child: Column(
                children: [
                  // text avec icon cross ou check pour mot de passe de 10 caractére
                  Row(children: [
                    Text('au moins 10 caractéres'),
                    Icon(
                      isGreat10 ? Icons.check : Icons.close,
                      color: isGreat10 ? Colors.green : Colors.red,
                    )
                  ]),
                  Row(children: [
                    Text('au moins 2 majuscules'),
                    Icon(
                      is2Maj ? Icons.check : Icons.close,
                      color: is2Maj ? Colors.green : Colors.red,
                    )
                  ]),
                  Row(children: [
                    Text('au moins 2 chiffres'),
                    Icon(
                      is2Chiffre ? Icons.check : Icons.close,
                      color: is2Chiffre ? Colors.green : Colors.red,
                    )
                  ]),
                  Row(children: [
                    Text('au moins 2 caractéres speciaux'),
                    Icon(
                      is2specialCarac ? Icons.check : Icons.close,
                      color: is2specialCarac ? Colors.green : Colors.red,
                    )
                  ])
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200, 50),
              ),
              onPressed: () async {
                if (widget.formKey.currentState!.validate()) {
                  await DBFirebase()
                      .signup(
                    widget.emailController.text,
                    widget.passwordController.text,
                  )
                      .then((value) {
                    if (value) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Enregistrer'),
                            content: const Text(
                                'Création d\'un compte effectuée avec succés ! \nUn email de vérification vous a été envoyé.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Erreur'),
                            content: const Text(
                                'Une erreur est survenue lors de la création de votre compte.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  });
                }
              },
              child: const Text('Signup'),
            ),
          ],
        ),
      ),
    );
  }
}
