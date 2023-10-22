import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../auth.dart';

class CreateClassPage extends StatelessWidget {
  final TextEditingController _classNameController = TextEditingController();


  void joinClass(String classId, BuildContext context) async {
    print(classId);

    String? email = Auth().currentUser?.email;
    DocumentReference userRef = await FirebaseFirestore.instance.collection(
        'User').doc(email);

    if (userRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please sign in to join a class.'),
      ));
    }

    await FirebaseFirestore.instance.collection('classes').doc(classId)
        .get()
        .then((doc) {
      if (doc.exists) {
        userRef.update({
          'enrolledCLasses': FieldValue.arrayUnion([classId])
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Class added succefully.'),
        ));
      } else {
        ScaffoldMessenger.of(context
        ).showSnackBar(SnackBar(
          content: Text('Class not found'),
        ));
      }
    });
  }

  void createClass(String className, BuildContext context) async {
    // Check if the class name already exists
    final classesCollection = FirebaseFirestore.instance.collection('classes');
    final classDoc = await classesCollection.doc(className).get();

    if (classDoc.exists) {
      // Class name already exists, show a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This class name is already taken.'),
        ),
      );
    } else {
      print("+++++++++++++++++++++++++++++++++++++++++++++++++++++");
      print(Auth().currentUser?.email);
      print('******************************************************');
      // Class name doesn't exist, create a new document
      await classesCollection.doc(className).set({
        'className': className,
        'createdBy': Auth().currentUser?.email,
      });

      joinClass(className, context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Class created succefully.'),
        duration: Duration(seconds: 2),
      ));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Class')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _classNameController,
              decoration: InputDecoration(labelText: 'Enter Class Name'),
            ),
            Text('Select a Class Photo:'),
            ElevatedButton(
              onPressed: () async {
                String className = _classNameController.text;
                if (className.isNotEmpty) {
                  createClass(className, context);
                } else {
                  // Handle empty class name
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter a class name.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Create Class'),
            ),
          ],
        ),
      ),
    );
  }
}
