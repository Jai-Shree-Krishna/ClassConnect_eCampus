import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../auth.dart';
import '../models/class.dart';
import '../models/announcement.dart';
import 'new_announcement.dart';
import 'new_material.dart';


class ClassDetailsPage extends StatefulWidget {
  late final Class currentClass;

  ClassDetailsPage({required this.currentClass     });

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
        title: Text(widget.currentClass.className),
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewAnnouncementPage(className: widget.currentClass.className)),
                    );
                  },
                  child: Text('New Announcement'),
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MaterialSharingWidget(classId: widget.currentClass.className)),
                    );
                  },
                  child: Text('New Material'),
                ),
              ),
              PopupMenuItem(
                value: 3,
                child: ElevatedButton(
                  onPressed: () {

                  },
                  child: Text('New Assignment'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          StreamSection(className: widget.currentClass.className),
          ClassSection(title: 'Classwork'),
          PeopleSection(classId: widget.currentClass.className),
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
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  ClassSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
        Positioned(
          bottom: 16.0, // Adjust the position as needed
          right: 16.0, // Adjust the position as needed
          child: _buildPopupMenuButton(),
        ),
      ],
    );
  }

  Widget _buildPopupMenuButton() {
    return ElevatedButton(
        onPressed: () async {
          // await _showNotification('Hari Testing', 'my testin my testing 123... 123');
        },
        child: Text('Click to notify.')
    );
  }


//
//
//   Future<void> _showNotification(String title, String content) async {
//
//
//     var androidDetails = AndroidNotificationDetails(
//         'channel_id', 'channel_name',
//         importance: Importance.max, priority: Priority.high);
//     var platformChannelSpecifics =
//     NotificationDetails(android: androidDetails);
//
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       content,
//       platformChannelSpecifics,
//     );
//   }
// }

}

class StreamSection extends StatelessWidget {
  late final String className;
  StreamSection({required this.className});

  final User? currentUser = FirebaseAuth.instance.currentUser; // Get the current user

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('classes').doc(className).collection('announcements').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No announcements available');
        }

        List<DocumentSnapshot> announcements = snapshot.data!.docs;

        return ListView.builder(
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            var announcement = announcements[index].data() as Map<String, dynamic>;
            var text = announcement['title'];
            var body = announcement['announcement'];
            var timestamp = announcement['timestamp'];
            var createdBy = announcement['createdBy'];

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.person),
              ), // Replace PhotoWidget with your widget
              title: Text(text ?? "no title"),
              subtitle: Text(body ?? "no body"),
              trailing: (currentUser != null && currentUser?.email == createdBy)
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Handle update here
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Handle delete here
                    },
                  ),
                ],
              ) : null,
              onTap: () {
                // Handle the announcement's body here
              },
            );
          },
        );
      },
    );
  }
}
//
//
// // _buildAnnouncementCard(
// // 'Important Announcement',
// // 'There will be a quiz on Monday. Be prepared!',
// // ),
// // _buildAssignmentCard(
// // 'Assignment 1',
// // 'Complete the exercises on pages 10-15.',
// // ),
// // _buildMaterialCard(
// // 'Study Materials',
// // 'Download the PDF notes for this week.',
// // ),
// // _buildPDFCard(
// // 'Sample PDF',
// // 'Sample PDF Document',
// // 'https://example.com/sample.pdf', // Replace with the actual PDF URL
// // ),
//
//
// Widget _buildAnnouncementCard(String title, String content) {
//   return Card(
//     elevation: 3.0,
//     margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//     child: ListTile(
//       title: Text(
//         title,
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       subtitle: Text(content),
//     ),
//   );
// }
//
// Widget _buildAssignmentCard(String title, String content) {
//   return Card(
//     elevation: 3.0,
//     margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//     child: ListTile(
//       title: Text(
//         title,
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       subtitle: Text(content),
//     ),
//   );
// }
//
// Widget _buildMaterialCard(String title, String content) {
//   return Card(
//     elevation: 3.0,
//     margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//     child: ListTile(
//       title: Text(
//         title,
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       subtitle: Text(content),
//     ),
//   );
// }
//
// Widget _buildPDFCard(String title, String description, String pdfUrl) {
//   return Card(
//     elevation: 3.0,
//     margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//     child: ListTile(
//       title: Text(
//         title,
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       subtitle: Text(description),
//       onTap: () {
//         // Implement opening PDF here (e.g., using a PDF viewer package)
//         // You can use the pdfUrl to load and display the PDF.
//         // Replace this with your PDF viewing logic.
//       },
//     ),
//   );
// }
//
//
//
//
//


class PeopleSection extends StatefulWidget {
  final String classId;

  PeopleSection({required this.classId});

  @override
  State<PeopleSection> createState() => _PeopleSectionState();
}

class _PeopleSectionState extends State<PeopleSection> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('User').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No users available');
        }

        List<DocumentSnapshot> users = snapshot.data!.docs;
        List<Widget> userWidgets = [];

        for (var userSnapshot in users) {
          var userData = userSnapshot.data() as Map<String, dynamic>;
          var userId = userSnapshot.id;
          var enrolledClasses = (userData['enrolledCLasses'] ?? []) as List<dynamic>;

          // Check if the user is enrolled in the specified class
          if (enrolledClasses.contains(widget.classId)) {
            var userName = userData['name'];
            var userEmail = userData['email'];

            print(userName ?? "no name");
            print(userEmail ?? "no email");

            if (userId != currentUser?.uid) {
              // Exclude the current user from the list
              userWidgets.add(
                _buildClassmatesRow(userName ?? userEmail, userEmail ?? "no email"),
              );
            }
          }
        }

        return ListView(
          children: userWidgets,
        );
      },
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
//
// _buildTeacherRow('Teacher 1', 'teacher1@example.com'),
// _buildTeacherRow('Teacher 2', 'teacher2@example.com'),
// _buildTeacherRow('Teacher 3', 'teacher3@example.com'),
// _buildClassmatesRow('Classmate 1', 'classmate1@example.com'),
// _buildClassmatesRow('Classmate 2', 'classmate2@example.com'),
// _buildClassmatesRow('Classmate 3', 'classmate3@example.com'),
// _buildClassmatesRow('Classmate 4', 'classmate4@example.com'),
// _buildClassmatesRow('Classmate 5', 'classmate5@example.com'),

// class PeopleSection extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       children: [
//         _buildTeacherRow('Teacher 1', 'teacher1@example.com'),
//         _buildTeacherRow('Teacher 2', 'teacher2@example.com'),
//         _buildTeacherRow('Teacher 3', 'teacher3@example.com'),
//         _buildClassmatesRow('Classmate 1', 'classmate1@example.com'),
//         _buildClassmatesRow('Classmate 2', 'classmate2@example.com'),
//         _buildClassmatesRow('Classmate 3', 'classmate3@example.com'),
//         _buildClassmatesRow('Classmate 4', 'classmate4@example.com'),
//         _buildClassmatesRow('Classmate 5', 'classmate5@example.com'),
//       ],
//     );
//   }
//
//   Widget _buildTeacherRow(String teacherName, String email) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: Colors.blue,
//         child: Icon(Icons.person),
//       ),
//       title: Text(teacherName),
//       subtitle: Row(
//         children: [
//           Icon(Icons.email),
//           SizedBox(width: 4.0),
//           Text(email),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildClassmatesRow(String studentName, String email) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: Colors.green,
//         child: Icon(Icons.person),
//       ),
//       title: Text(studentName),
//       subtitle: Row(
//         children: [
//           Icon(Icons.email),
//           SizedBox(width: 4.0),
//           Text(email),
//         ],
//       ),
//     );
//   }
// }