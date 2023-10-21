import 'package:firebase_auth/firebase_auth.dart';
import 'package:classroom_project_testing/auth.dart';
import 'package:classroom_project_testing/pages/home_page.dart';
import 'package:classroom_project_testing/pages/login_register_page.dart';
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return ClassListPage();
          } else {
            return const LoginPage();
          }
        }
    );
  }
}
