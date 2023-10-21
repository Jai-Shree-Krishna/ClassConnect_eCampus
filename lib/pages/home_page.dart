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



class ClassListPage extends StatelessWidget {


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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('classes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot> classDocuments = snapshot.data!.docs;

          // print('=============================================******************==================');
          // print(classDocuments);
          // print('=========================================********************======================');
          if (classDocuments.isEmpty) {
            return Center(child: Text('No classes available.'));
          }

          // return ListView.builder(
          //   itemCount: classDocuments.length,
          //   itemBuilder: (context, index) {
          //     Map<String, dynamic> data = classDocuments[index].data() as Map<String, dynamic>;
          //     String className = data['className'];
          //     String createdBy = data['createdBy'];
          //     return Container(
          //       child: Column(
          //         children: [
          //
          //         Text(className),
          //         Text(createdBy),
          //         // SizedBox.fromSize(20/)
          //         ],
          //       ),
          //       // You can add other class details here
          //     );
          //   },
          // );

          return ListView.separated(
            itemCount: classDocuments.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              Map<String, dynamic> data = classDocuments[index].data() as Map<String, dynamic>;
              String className = data['className'] ?? "noName";
              String createdBy = data['createdBy'] ?? "noName";
              return ListTile(
                title: Text(
                  className,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Teacher: ${createdBy}'),
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
                      // Handle the "Unenroll" action here
                      // You can add your logic to unenroll the student from the class
                      // For example, show a confirmation dialog and process the unenrollment.
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => UnenrollPage(currentClass),
                      //   ),
                      // );
                    }
                  },
                ),
                onTap: () {
                  // Navigate to a new page when the ListTile is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDetailsPage(new Class(className:className, createdBy: createdBy)),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}



// class Class {
//   final String name;
//   final String teacher;
//
//   Class(this.name, this.teacher);
// }

class ClassDetailsPage extends StatefulWidget {
  final Class currentClass;

  ClassDetailsPage(this.currentClass);

  @override
  _ClassDetailsPageState createState() => _ClassDetailsPageState();
}

class _ClassDetailsPageState extends State<ClassDetailsPage> {
  int _currentIndex = 0;
  PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.currentClass!.className),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          StreamSection(),
          ClassSection(title: 'Classwork'),
          PeopleSection(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavBarTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Stream',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Classwork',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'People',
          ),
        ],
      ),
    );
  }
}


class ClassSection extends StatelessWidget {
  final String title;

  ClassSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class StreamSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildAnnouncementCard(
          'Important Announcement',
          'There will be a quiz on Monday. Be prepared!',
        ),
        _buildAssignmentCard(
          'Assignment 1',
          'Complete the exercises on pages 10-15.',
        ),
        _buildMaterialCard(
          'Study Materials',
          'Download the PDF notes for this week.',
        ),
        _buildPDFCard(
          'Sample PDF',
          'Sample PDF Document',
          'https://example.com/sample.pdf', // Replace with the actual PDF URL
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(String title, String content) {
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(content),
      ),
    );
  }

  Widget _buildAssignmentCard(String title, String content) {
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(content),
      ),
    );
  }

  Widget _buildMaterialCard(String title, String content) {
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(content),
      ),
    );
  }

  Widget _buildPDFCard(String title, String description, String pdfUrl) {
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        onTap: () {
          // Implement opening PDF here (e.g., using a PDF viewer package)
          // You can use the pdfUrl to load and display the PDF.
          // Replace this with your PDF viewing logic.
        },
      ),
    );
  }
}

class PeopleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildTeacherRow('Teacher 1', 'teacher1@example.com'),
        _buildTeacherRow('Teacher 2', 'teacher2@example.com'),
        _buildTeacherRow('Teacher 3', 'teacher3@example.com'),
        _buildClassmatesRow('Classmate 1', 'classmate1@example.com'),
        _buildClassmatesRow('Classmate 2', 'classmate2@example.com'),
        _buildClassmatesRow('Classmate 3', 'classmate3@example.com'),
        _buildClassmatesRow('Classmate 4', 'classmate4@example.com'),
        _buildClassmatesRow('Classmate 5', 'classmate5@example.com'),
      ],
    );
  }

  Widget _buildTeacherRow(String teacherName, String email) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Icon(Icons.person),
      ),
      title: Text(teacherName),
      subtitle: Row(
        children: [
          Icon(Icons.email),
          SizedBox(width: 4.0),
          Text(email),
        ],
      ),
    );
  }

  Widget _buildClassmatesRow(String studentName, String email) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green,
        child: Icon(Icons.person),
      ),
      title: Text(studentName),
      subtitle: Row(
        children: [
          Icon(Icons.email),
          SizedBox(width: 4.0),
          Text(email),
        ],
      ),
    );
  }
}

class CreateClassPage extends StatelessWidget {
  final TextEditingController _classNameController = TextEditingController();

  BuildContext get context => context;

  Future<void> createClass(String className) async {
    // Check if the class name already exists
    final classesCollection = FirebaseFirestore.instance.collection('classes');
    final classDoc = await classesCollection.doc(className).get();

    if (classDoc.exists) {
      // Class name already exists, show a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This class name is already taken.'),
          duration: Duration(seconds: 3),
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
            ElevatedButton(
              onPressed: () async {
                String className = _classNameController.text;
                if (className.isNotEmpty) {
                  await createClass(className);
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
