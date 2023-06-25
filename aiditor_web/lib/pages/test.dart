import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  // sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> loadUserProjects() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('aiditor_projects')
        .where('user_uid', isEqualTo: user.uid)
        .get();

    final userProjects = querySnapshot.docs;
    print('Number of user projects: ${userProjects.length}');
    print('User Projects: $userProjects');

    return userProjects;
  }

  Future<void> createProject(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String projectName = '';
    String fileName = '';
    String projectType = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Project'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Project Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a project name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    projectName = value!;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'File Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a file name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fileName = value!;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Type',
                  ),
                  value: projectType,
                  items: ['LOL', 'LIFESTYLE'].map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      projectType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a project type';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();

                  final projectId = DateTime.now().microsecondsSinceEpoch.toString().substring(0, 8);
                  final projectDocId = FirebaseFirestore.instance.collection('aiditor_projects').doc().id;

                  final projectData = {
                    'project_name': projectName,
                    'created_date': DateFormat('dd-MM-yyyy').format(DateTime.now()),
                    'user_uid': user.uid,
                    'project_id': projectId,
                  };

                  final videoData = {
                    'video_filename': fileName,
                    'type': projectType,
                  };

                  try {
                    await FirebaseFirestore.instance
                        .collection('aiditor_projects')
                        .doc(projectDocId)
                        .set(projectData);

                    await FirebaseFirestore.instance
                        .collection('aiditor_projects')
                        .doc(projectDocId)
                        .collection('aidited_videos')
                        .doc()
                        .set(videoData);

                    // Reload projects
                    setState(() {});

                    Navigator.of(context).pop(); // Close the dialog
                  } catch (error) {
                    print('Error creating project: $error');
                    // Handle error
                  }
                }
              },
              child: Text('Create'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        centerTitle: true,
        title: ElevatedButton(
          onPressed: () => createProject(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Create Project'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Reload projects
              setState(() {});
              signUserOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
            future: loadUserProjects(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                // Display user's projects as cards
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Number of columns in the grid
                    childAspectRatio: 4.0,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final project = snapshot.data![index].data();
                    final title = project['project_name'] ?? 'No Project Name';
                    final creationDate = project['created_date'] ?? 'No Creation Date';
                    final projectId = project['project_id'] ?? 'No Project ID';

                    return Card(
                      child: ListTile(
                        title: Text(title + '                                                         ' + projectId),
                        subtitle: Text(creationDate),
                        // Add more project details if needed
                      ),
                    );
                  },
                );
              } else {
                // Display "No project" text and create project button
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No project',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => createProject(context),
                      child: Text('Create a project'),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
