import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth.dart';

class JoinClassPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Join Class')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter Class ID'),
            ),
            ElevatedButton(
              onPressed: () {
                final String code = _controller.text;
                joinClass(code, context);
              },
              child: Text('Join Class'),
            ),
          ],
        ),
      ),
    );
  }
}

  // void joinClass (String classId, BuildContext context) async {
  // print('************************CLASS ID*************************************');
  // print(classId);
  // print('************************CLASS ID*************************************');
  //
  // FirebaseFirestore.instance.collection('classes').doc('secondclass').get().then((doc)=>{
  //   if(doc.exists) {
  //     print('exists'),
  //     print(doc['className'])
  //   } else {
  //     print('does not exists')
  //   }
  // });
  //
  //   await FirebaseFirestore.instance.collection('classes').doc(classId).get().then((doc)=>{
  //     if(doc.exists) {
  //   // Reference to the user's document
  //   FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.email).update({
  //     'enrolledClasses': FieldValue.arrayUnion([classId]),
  //   }),
  //
  //      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('You have successfully joined the class.'),
  //     ))
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('No such class exists.'),
  //     ))
  //     }
  //   });
  // }


void joinClass(String classId, BuildContext context) async {
  print(classId);

  String? email = Auth().currentUser?.email;
  DocumentReference userRef = await FirebaseFirestore.instance.collection('User').doc(email);

  if(userRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please sign in to join a class.'),
      ));
  }

  await FirebaseFirestore.instance.collection('classes').doc(classId).get().then((doc) {
    if(doc.exists) {

      userRef.update({
        'enrolledCLasses': FieldValue.arrayUnion([classId])
      });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Class added succefully.'),
        ));
    } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Class not found'),
        ));
    }
  });

  // Reference to the class document
  // DocumentReference classDocRef = FirebaseFirestore.instance.collection('classes').doc(classId);

  // Check if the class document exists
  // DocumentSnapshot classDoc = await classDocRef.get();

  // if (classDoc.exists) {
    // Reference to the user's document
    // String? userEmail = FirebaseAuth.instance.currentUser?.email;

    // if (userEmail != null) {
    //   DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userEmail);
    //
    //   try {
    //     Update the user's 'enrolledClasses' array with classId
        // await userDocRef.update({
        //   'enrolledClasses': FieldValue.arrayUnion([classId]),
        // });
      // } catch (e) {
      //   print(e);
      // }
      //
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('You have successfully joined the class.'),
      // ));
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text('Please sign in to join a class.'),
    //   ));
    // }
  // } else {
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     content: Text('No such class exists.'),
  //   ));
  // }
}
