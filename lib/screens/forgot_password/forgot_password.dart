import 'package:flutter/material.dart';

import 'components/form_forgot.dart';

class ForgotPage extends StatefulWidget {
  const ForgotPage({
    super.key,
  });

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Muscu App - Mot de passe oublié'),
      ),
      body: FormForgotPassword(
        emailController: emailController,
        formKey: formKey,
      ),
    );
  }
}
