import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;
  
  // sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  //create a function loading and returning the user's projects from firestore
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> loadUserProjects() async {
    final userProjects = await FirebaseFirestore.instance
        .collection('aiditor_projects')
        .where('user_uid', isEqualTo: user.uid)
        .get();
    return userProjects.docs;
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
          child: Text(
        "LOGGED IN AS: ${user.email!}\n\nUID: ${user.uid}",
        style: const TextStyle(fontSize: 20),
      )),
    );
  }
}