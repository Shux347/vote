// ignore_for_file: prefer_const_constructors, use_super_parameters

import 'package:flutter/material.dart';

class LoginSuccessScreen extends StatelessWidget {
  final String name;

  const LoginSuccessScreen({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Success'),
      ),
      body: Center(
        child: Text('Welcome, $name!'),
      ),
    );
  }
}
