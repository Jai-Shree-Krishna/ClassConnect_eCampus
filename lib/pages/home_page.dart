import 'package:classroom_project_testing/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/class.dart';
import 'class_details_page.dart';
import 'create_class_page.dart';
import 'join_class_page.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List <String> classOfUser = [];
  List <Class> classes = [];

  void getAllClasses() async {
    String? email = Auth().currentUser!.email;

    List <String> classOfUser1 = [];
    List <Class> classes1 = [];

    final userDocument = await FirebaseFirestore.instance.collection('User').doc(email).get();
    final dynamic data = userDocument.data()?['enrolledCLasses'] ?? [];

    if (data is List<dynamic>) {
      classOfUser1.addAll(data.map((item) {
        return item.toString();
      }));
    }

    if (classOfUser1.isNotEmpty) {
      for (int i = 0; i < classOfUser1.length; i++) {
        final classDocument = await FirebaseFirestore.instance.collection('classes').doc(classOfUser1[i]).get();
        if (classDocument.exists) {
          final dynamic data = classDocument.data();
          // print(classDocument.data());
          String className = data!['className'] ?? "no name";
          String createdBy = data!['createdBy'] ?? "no creator";

          print(classDocument.data());
          Class currentClass = new Class(className: className, createdBy: createdBy);
          classes1.add(currentClass);
        }
      }
    }

    setState(() {
      this.classes = classes1;
      this.classOfUser = classOfUser1;
    });

  }

  Future<void> signOut() async {
    // Your sign-out code
    await Auth().signOut();
    print('-------------sign out ------------');
  }

  @override
  void initState() {
    // TODO: implement initState
    getAllClasses();
  }

  void removeClassOfUser(Class c) async {
    String? email = Auth().currentUser!.email;
    String className = c.className;

    final userDocument = await FirebaseFirestore.instance.collection('User').doc(email);

    await userDocument.update({
      'enrolledCLasses': FieldValue.arrayRemove([className])
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Class removed succefully.'),
    ));

    print(className + " is removed from uesr $email");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classroom Dashboard '),
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateClassPage()),
                    );
                  },
                  child: Text('Create Class'),
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => JoinClassPage()),
                    );
                  },
                  child: Text('Join Class'),
                ),
              ),
              PopupMenuItem(
                value: 3,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle "Sign Out" option
                    signOut();
                  },
                  child: Text('Sign Out'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getAllClasses();
          print('Refreshing...');
        },
        child: ListView.separated(
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                classes[index].className != "" ? classes[index].className : "no name",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(classes[index].createdBy != "" ? classes[index].createdBy : "no creator"),
              trailing: PopupMenuButton(
                icon: Icon(Icons.more_vert),
                itemBuilder: (context) {
                  return <PopupMenuEntry>[
                    PopupMenuItem(
                      value: 'unenroll',
                      child: Text('Unenroll'),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == 'unenroll') {
                    removeClassOfUser(classes[index]);
                  }
                },
              ),
              onTap: () {
                // Navigate to a new page when the ListTile is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassDetailsPage(currentClass: classes[index],),
                  ),
                );
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider(height: 20, thickness: 1);
          },
          itemCount: classes.length,
        ),
      ),
    );
  }

}

