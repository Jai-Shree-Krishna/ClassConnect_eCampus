import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../auth.dart';
import '../models/class.dart';
import '../models/announcement.dart';


class ClassDetailsPage extends StatefulWidget {
  late final Class currentClass;

  ClassDetailsPage({required this.currentClass});

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

class PeopleSection extends StatefulWidget {
  const PeopleSection({super.key});

  @override
  State<PeopleSection> createState() => _PeopleSectionState();
}

class _PeopleSectionState extends State<PeopleSection> {

  @override
  void initState() {
    // TODO: implement initState

  }

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