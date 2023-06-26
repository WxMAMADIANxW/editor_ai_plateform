import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:player_js/player_js.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String? projectId;

  ProjectDetailsScreen({required this.projectId});

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late String _currentVideoUrl;
  List<String> _videosToDownload = [];

  @override
  void initState() {
    super.initState();
    _currentVideoUrl = getProjectVideos().then((value) => value.first.data()?['url']).toString();
  }

  Widget _buildVideo(String url) {
    return Player(
                  videoUrl:
                  url,
                  subtitles: {
                  },
                  height: 700,
                  width: 900,
    );
  }

  void deleteProject() async {
    final docId = await FirebaseFirestore.instance
        .collection('aiditor_projects')
        .where('project_id', isEqualTo: widget.projectId)
        .get()
        .then((value) => value.docs.first.id);

    await FirebaseFirestore.instance.collection('aiditor_projects').doc(docId).delete();
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getProjectVideos() async {
    final docId = await FirebaseFirestore.instance
        .collection('aiditor_projects')
        .where('project_id', isEqualTo: widget.projectId)
        .get()
        .then((value) => value.docs.first.id);

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('aiditor_projects/$docId/aidited_videos')
            .get();

    final projectVideos = querySnapshot.docs;

    print('DocId: $docId');
    print('Number of project videos: ${projectVideos.length}');
    print('Project videos: $projectVideos');

    return projectVideos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Details'),
        actions: [
          IconButton(
            onPressed: () {
              deleteProject();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
        future: getProjectVideos(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final projectVideos = snapshot.data!;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(40),
                    child: _buildVideo(projectVideos.first.data()!['url'].toString()),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.all(40),
                    child: ListView.builder(
                      itemCount: projectVideos.length,
                      itemBuilder: (context, index) {
                        final videoData = projectVideos[index].data();
                        final videoUrl = videoData?['url'];
                        final videoName = videoData?['filename'];
                        final videoId = "This is a result clip from the raw video";
                        final isSelected = _videosToDownload.contains(videoUrl);
                        return Card(
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                _currentVideoUrl = videoUrl ?? '';
                              });
                            },
                            title: Text(videoName ?? ''),
                            subtitle: Text(videoId ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.play_arrow),
                                  onPressed: () {
                                    setState(() {
                                      _currentVideoUrl = videoUrl ?? '';
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(isSelected ? Icons.remove_circle : Icons.add_circle),
                                  onPressed: () {
                                    setState(() {
                                      if (isSelected) {
                                        _videosToDownload.remove(videoUrl);
                                      } else {
                                        _videosToDownload.add(videoUrl);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle download functionality
          print('Videos to download: $_videosToDownload');
        },
        child: Icon(Icons.download),
      ),
    );
  }
}
