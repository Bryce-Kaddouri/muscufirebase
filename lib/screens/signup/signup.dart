import 'package:flutter/material.dart';

import 'components/form_signup.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  // global key for the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // controller for email
  final TextEditingController _emailController = TextEditingController();
  // controller for password
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
      ),
      body: FormSignup(
        emailController: _emailController,
        passwordController: _passwordController,
        formKey: _formKey,
      ),
    );
  }
}
