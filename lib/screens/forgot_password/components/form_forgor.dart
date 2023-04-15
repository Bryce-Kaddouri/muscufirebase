import 'package:flutter/material.dart';
import 'package:muscucards/screens/signin/signin.dart';

import '../../../services/firebase.dart';

class FormForgotPassword extends StatefulWidget {
  GlobalKey<FormState> formKey;
  TextEditingController emailController;

  FormForgotPassword({
    super.key,
    required this.formKey,
    required this.emailController,
  });

  @override
  State<FormForgotPassword> createState() => _FormForgotPasswordState();
}

class _FormForgotPasswordState extends State<FormForgotPassword> {
  // regex for email
  RegExp regEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: widget.formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Mot de passe oublié', style: TextStyle(fontSize: 40)),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200, 50),
              ),
              onPressed: () async {
                if (widget.formKey.currentState!.validate()) {
                  await DBFirebase()
                      .resetPassword(
                    widget.emailController.text,
                  )
                      .then((value) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Réinitialiser'),
                          content: const Text(
                              'Réinitialisation effectuée avec succés ! \nUn email de vérification vous a été envoyé.'),
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
                  });
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }
}
