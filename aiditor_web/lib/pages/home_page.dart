import 'dart:convert';
import 'dart:html';
 import 'package:http_parser/http_parser.dart';
import 'package:aiditor_web/pages/project_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

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
        .where('user_id', isEqualTo: user.uid)
        .get();

    final userProjects = querySnapshot.docs;

    return userProjects;
  }

  Future<void> createProject(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String projectName = '';
    String fileName = '';
    String projectType = 'lol';
    // ignore: prefer_typing_uninitialized_variables
    var videoFile;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Project'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles();

                        if (result != null) {
                          videoFile = result.files.first;

                          setState(() {
                            fileName = videoFile.name;
                          });
                        }
                      },
                      child: const Text('Select File'),
                    ),
                    const SizedBox(width: 8),
                    Text(fileName),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Type',
                  ),
                  value: projectType,
                  items: [
                    'lol',
                    'lifestyle',
                  ].map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
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

                  final projectId = DateTime.now()
                      .microsecondsSinceEpoch
                      .toString()
                      .substring(0, 8);
                  final projectDocId =
                      FirebaseFirestore.instance.collection('aiditor_projects').doc().id;

                  final projectData = {
                    'project_name': projectName,
                    'created_date': DateFormat('dd-MM-yyyy').format(DateTime.now()),
                    'user_id': user.uid,
                    'project_id': projectId,
                    'project_type': projectType,
                  };
                  var date = DateFormat('yyyyMMdd').format(DateTime.now());

                  final fileNameSub = fileName.substring(0, 8);
                  final fileNameWithoutSpaces = fileNameSub.replaceAll(' ', '');
                  final fileNameWithoutUnderScores =
                      fileNameWithoutSpaces.replaceAll('_', '');
                  final fileNameWithoutSpecialCharacters =
                      fileNameWithoutUnderScores.replaceAll(RegExp(r'[^\w\s]+'), '');
                  final finalFileName =
                      fileNameWithoutSpecialCharacters.substring(0, fileNameWithoutSpecialCharacters.length - 3);

                  var s3Filename = "$projectId/${finalFileName}_${projectType}_$date.mp4";
                  print(s3Filename);

                  final videoData = {
                    'project_id': projectId,
                    'project_name': projectName,
                    'video_filename': fileName,
                    'type': projectType,
                    's3filename': s3Filename,
                    'created_date': DateFormat('dd-MM-yyyy').format(DateTime.now()),
                  };

                  try {
                    await FirebaseFirestore.instance
                        .collection('aiditor_projects')
                        .doc(projectDocId)
                        .set(projectData);

                    // await FirebaseFirestore.instance
                    //     .collection('aiditor_projects')
                    //     .doc(projectDocId)
                    //     .collection('aidited_videos')
                    //     .doc()
                    //     .set(videoData);

                    

                    var url = 'https://7ga1us6g26.execute-api.us-east-1.amazonaws.com/v1/url/$s3Filename';

                    print("Sending request to backend");
                    print("url: $url");
                    
                    // Send request to backend to get signed URL
                    var getSignedUrlResponse = await http.get(
                      Uri.parse(url),
                      headers: {
                        "Access-Control-Allow-Origin": "*", // Required for CORS support to work
                        "Access-Control-Allow-Credentials":
                            'true', // Required for cookies, authorization headers with HTTPS
                        "Access-Control-Allow-Headers":
                            "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
                        "Access-Control-Allow-Methods": "POST, GET,OPTIONS"
                      }
                    );
                    

                    // Check if the response was successful
                    print(getSignedUrlResponse.statusCode);
                    print(videoFile.runtimeType);

                    if(getSignedUrlResponse.statusCode == 200){
                      print("Response was successful");

                      //decode response body to json
                      print('decode response body to json');
                      var responseBody = jsonDecode(getSignedUrlResponse.body);

                      //get signed url from response body
                      print('get signed url from response body');
                      var signedUrl = responseBody['url'];

                      // get Fields from signed URL
                      print('get Fields from signed URL');
                      var fields = responseBody['fields'];

                      // Create multipart request for uploading the video
                      print('Create multipart request for uploading the video');
                      var request = http.MultipartRequest('POST', Uri.parse(signedUrl));

                      // Add fields to multipart request
                      print('Add fields to multipart request');
                      fields.forEach((key, value) {
                        request.fields[key] = value;
                        //print('$key: $value');
                      });
                      request.fields['key'] = s3Filename;

                      // Create multipart file from video file
                      print('Create multipart file from video file');
                      var multipartFile = http.MultipartFile.fromBytes('file', videoFile.bytes, filename: s3Filename, contentType: MediaType('video', 'mp4')
                      );
                      // Add multipart file to multipart request
                      print('Add multipart file to multipart request');
                      request.files.add(multipartFile);

                      // Send multipart request
                      print('Send multipart request');
                      var response = await request.send();

                      // Check if the response was successful
                      print('Check if the response was successful');
                      if(response.statusCode == 204){
                        print("Video uploaded successfully");
                      }else{
                        print("Video upload failed");
                      }

                    }else{
                      throw Exception('Failed to get signed URL');
                    }

                    // Reload projects
                    setState(() {});

                    Navigator.of(context).pop(); // Close the dialog
                  } catch (error) {
                    print('Error creating project: $error');
                    // Handle error
                  }
                }
              },
              child: const Text('Create'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
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
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
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
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProjectDetailsScreen(projectId: projectId),
                            ),
                          );
                        },
                        title: Text(title + '                                                         ' + projectId),
                        subtitle: Text(creationDate),
                      ),
                    );
                  },
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No project',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => createProject(context),
                      child: const Text('Create a project'),
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
