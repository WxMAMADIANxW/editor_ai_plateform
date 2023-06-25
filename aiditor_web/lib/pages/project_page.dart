import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final String projectId;

  ProjectDetailsScreen({required this.projectId});

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getProjectVideos() async {

    final docId = await FirebaseFirestore.instance
        .collection('aiditor_projects').where('project_id', isEqualTo: projectId).get()
        .then((value) => value.docs.first.id);

    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('aiditor_projects/$docId/aidited_videos')
        .get();

    final projectVideos = querySnapshot.docs;
    
    print('DocId: $docId');
    print('Number of project videos: ${projectVideos.length}');
    print('Project videos: $projectVideos');

    return projectVideos;
  }

  void deleteProject() async {
    final docId = await FirebaseFirestore.instance
        .collection('aiditor_projects').where('project_id', isEqualTo: projectId).get()
        .then((value) => value.docs.first.id);

    await FirebaseFirestore.instance
        .collection('aiditor_projects')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Handle delete project
              deleteProject();
            },
          ),
        ],
      ),
    );
  }
}
