import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muscucards/screens/forgot_password/forgot_password.dart';
import 'package:muscucards/services/firebase.dart';

import '../../seance/seance.dart';
import '../../signup/signup.dart';

class FormLogin extends StatefulWidget {
  GlobalKey<FormState> formKey;
  TextEditingController emailController;
  TextEditingController passwordController;

  FormLogin({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<FormLogin> createState() => _FormLoginState();
}

class _FormLoginState extends State<FormLogin> {
  bool isLoading = false;
  bool passwordVisible = false;
  RegExp regEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  RegExp regPassword = RegExp(
      r'^(?=.*?[A-Z].*?[A-Z])(?=.*?[0-9].*?[0-9])(?=.*?[!@#$%^&*()].*?[!@#$%^&*()])[A-Za-z0-9!@#$%^&*()]{10,}$');

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Form(
        key: widget.formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Authentification', style: TextStyle(fontSize: 40)),
            const SizedBox(
              height: 60,
            ),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir une adresse mail';
                } else if (!regEmail.hasMatch(value)) {
                  return 'Email invalide';
                }
                return null;
              },
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
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir un mot de passe';
                } else if (!regPassword.hasMatch(value)) {
                  return 'Mot de passe invalide';
                }
                return null;
              },
              obscureText: !passwordVisible,
              controller: widget.passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusColor: Colors.blue,
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPage(),
                  ),
                );
              },
              child: Text('Mot de passe oublié ?'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignupPage(),
                  ),
                );
              },
              child: Text('Pas encore de compte ?'),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200, 50),
              ),
              onPressed: () {
                setState(
                  () {
                    isLoading = true;
                  },
                );
                if (widget.formKey.currentState!.validate()) {
                  DBFirebase()
                      .login(widget.emailController.text,
                          widget.passwordController.text)
                      .then(
                    (value) {
                      if (value != null) {
                        UserCredential userCredential = value;
                        if (userCredential.user!.emailVerified) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SeancePage(
                                uid: value.user!.uid,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                'Erreur: Email non vérifié !',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              'Erreur: Email ou Mot de passe incorrect !',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
                setState(() {
                  isLoading = false;
                });
              },
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
