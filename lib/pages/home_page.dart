import 'package:classroom_project_testing/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:classroom_project_testing/pages/create_class_page.dart';
// import 'package:classroom_project_testing/pages/join_class_page.dart';

class Class{
  late final String className;
  late final String createdBy;

  Class({required this.className, required this.createdBy});
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  String? email = '';
  late Future <List <String>> classes;
  late  List <Class> allClass;

  void initState()  {
    super.initState();

    if(Auth().currentUser == Null) {
      Navigator.pop(context);
    } else {
      email = Auth().currentUser!.email;
    }

    classes =  getEnrolledClasses();

    print(email);
    print(classes);
  }

  Future<List<String>> getEnrolledClasses() async {
    List<String> enrolledClasses = [];

    String? emailId = Auth().currentUser!.email;
    print(emailId);

    Map<String, dynamic>? data;
    await FirebaseFirestore.instance.collection('User').doc(emailId).get().then((doc) => {
    if (doc.exists) {
        print(doc.data()),
    print('doc exists====================='),
    data = doc.data(),
    print(data!['enrolledCLasses']),

    if (data != null && data!['enrolledCLasses'] != null) {
      enrolledClasses = List<String>.from(data?['enrolledCLasses']),
    } else {
    print('no classes found'),
    }
    } else {
    print('doc does not exist==============='),
    }
    });

    print(enrolledClasses.length);
    return enrolledClasses;
  }

  Future<void> signOut() async {
    // Your sign-out code
    await Auth().signOut();
    print('-------------sign out ------------');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
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
      body: FutureBuilder<List<String>>(
        future: classes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }  else {
            // Display the list of enrolled classes in a ListView.builder
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index]),
                );
              },
            );
            // return DisplayClasses(classUids:classes);
          }
        },
      ),
    );
  }
}



class CreateClassPage extends StatefulWidget {
  const CreateClassPage({super.key});

  @override
  State<CreateClassPage> createState() => _CreateClassPageState();
}

class _CreateClassPageState extends State<CreateClassPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


class JoinClassPage extends StatefulWidget {
  const JoinClassPage({super.key});

  @override
  State<JoinClassPage> createState() => _JoinClassPageState();
}

class _JoinClassPageState extends State<JoinClassPage> {
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
void joinClass(String classId, BuildContext context) async {
  print('************************CLASS ID*************************************');
  print(classId);
  print('************************CLASS ID*************************************');

  FirebaseFirestore.instance.collection('classes').doc(classId).get().then((doc) async {
    if(doc.exists) {
      print('================================================');
      print('doc exsit');
      print('=================================================');
      String? userEmail = FirebaseAuth.instance.currentUser?.email;

      if (userEmail != null) {
        DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userEmail);

        if(userDocRef != null) {
          try {
            // Update the user's 'enrolledClasses' array with classId
            await userDocRef.update({
              'enrolledCLasses': FieldValue.arrayUnion([classId]),
            });
          } catch (e) {
            print(e);
          }
        } else {
          print('user doc ref is null=================');
        }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('You have successfully joined the class.'),
      ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please sign in to join a class.'),
        ));
      }
    } else {
      print('================================================');
      print('doc does not exsit');
      print('=================================================');

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('No such class exists.'),
            ));
    }
  });
}
