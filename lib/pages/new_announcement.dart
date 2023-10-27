import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../auth.dart';

class NewAnnouncementPage extends StatefulWidget {

  late final String className;
  NewAnnouncementPage({required this.className});

  @override
  _NewAnnouncementPageState createState() => _NewAnnouncementPageState();
}

class _NewAnnouncementPageState extends State<NewAnnouncementPage> {
  TextEditingController _announcementController = TextEditingController();
  TextEditingController _titlecontroller = TextEditingController();

  Future<void> addAnnouncementToClass(String classId, String title, String announcementText) async {
    try {
      // Get a reference to the announcements collection of the specified class
      CollectionReference classAnnouncements = FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('announcements');


      String userId = Auth().currentUser!.email ?? "no creator";

      // Add a new announcement document
      await classAnnouncements.add({
        'title': title,
        'announcement': announcementText,
        'timestamp': FieldValue.serverTimestamp(),
        'createdBy': userId,
      });

    } catch (e) {
      print('Error adding announcement: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titlecontroller,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _announcementController,
              decoration: InputDecoration(labelText: 'Announcement Text'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String title = _titlecontroller.text;
                String announcement = _announcementController.text;

                if(title != null && announcement != null) {
                  addAnnouncementToClass(widget.className, title, announcement);
                }

                Navigator.pop(context);

              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
