import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

class MaterialSharingWidget extends StatefulWidget {
  final String classId;

  MaterialSharingWidget({required this.classId});

  @override
  _MaterialSharingWidgetState createState() => _MaterialSharingWidgetState();
}

class _MaterialSharingWidgetState extends State<MaterialSharingWidget> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> uploadedFiles = [];
  TextEditingController titleController = TextEditingController();

  Future<void> _uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        PlatformFile pickedFile = result.files.single;
        final ref = FirebaseStorage.instance
            .ref()
            .child('materials')
            .child(widget.classId)
            .child(pickedFile.name);

        await ref.putFile(pickedFile.bytes! as File);

        final downloadUrl = await ref.getDownloadURL();
        final createdBy = currentUser?.email;

        setState(() {
          uploadedFiles.add({
            'url': downloadUrl,
            'title': titleController.text,
            'createdBy': createdBy,
          });
        });

        // Clear the title field
        titleController.clear();
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> _openFile(String url) async {
    await OpenFile.open(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Material Sharing'),
      ),
      body: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'File Title',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _uploadFile();
            },
            child: Text('Upload File'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: uploadedFiles.length,
              itemBuilder: (context, index) {
                final file = uploadedFiles[index];
                return ListTile(
                  title: Text(file['title']),
                  subtitle: Text('Uploaded by: ${file['createdBy']}'),
                  onTap: () {
                    _openFile(file['url']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
