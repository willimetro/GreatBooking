import 'package:flutter/material.dart';

class LoginSignUpPage extends StatefulWidget {
  
  @override
  _LoginSignUpPageState createState() => _LoginSignUpPageState();
}

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Great Booking Login'),
      ),
      body: Container(
        child: Text('Hola Great Booking login'),
      ),
    );
  }
}