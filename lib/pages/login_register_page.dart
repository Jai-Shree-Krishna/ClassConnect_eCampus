import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String ? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future <void> signInWithEmailAndPAssword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future <void> createUserWithEmailAndPassword() async {
      try {
        await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text,
        ).whenComplete(() => FirebaseFirestore.instance.collection('User').doc(_controllerEmail.text).set(
            {
          'email': _controllerEmail.text,
          'password': _controllerPassword.text,
          'enrolledCLasses': [],
          'doneAssignment': 0,
          'liveAssignment': 0,
          'missingAssignment': 0,
        }));
      } on  FirebaseAuthException catch (e) {
          setState(() {
            errorMessage = e.message;
          });
      }
  }

  Widget _title() {
      return const Text('Firebase Auth');
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
    ) {
      return TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
        ),
      );
  }

  Widget _errorMessage() {
      return Text(errorMessage == '' ? '' : '$errorMessage');
  }

  Widget _submitButton() {
      return ElevatedButton(
          onPressed: isLogin ? signInWithEmailAndPAssword : createUserWithEmailAndPassword,
          child: Text(isLogin ? 'Login' : 'Register')
      );
  }

  Widget _loginRegistrationButton() {
      return TextButton(
          onPressed: () {
            setState(() {
              isLogin = !isLogin;
            });
          },
          child: Text(isLogin ? 'Register instead' : 'Login insted')
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _title(),
        ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _entryField('email', _controllerEmail),
            _entryField('password', _controllerPassword),
            _errorMessage(),
            _submitButton(),
            _loginRegistrationButton(),
          ],
        ),
      ),
    );
  }
}

class UserModel {
  late final String email;
  late final String password;
  late  List <String> enrolledClasses;
  late final int missingAssignment;
  late final int liveAssignment;
  late final int doneAssignment;

  UserModel({
    required this.email,
    required this.password,
    this.enrolledClasses = const [],
    this.doneAssignment = 0,
    this.liveAssignment = 0,
    this.missingAssignment = 0,
});

}