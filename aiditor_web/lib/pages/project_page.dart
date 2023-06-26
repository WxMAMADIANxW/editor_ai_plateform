import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_iframe_plus/youtube_player_iframe_plus.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String? projectId;

  ProjectDetailsScreen({required this.projectId});

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late YoutubePlayerController _controller;
  late String _currentVideoUrl;

  @override
  void initState() {
    super.initState();


    _currentVideoUrl = '';
    _controller = YoutubePlayerController(
      initialVideoId: '',
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  Widget _buildVideo(String url) {
    final videoId = YoutubePlayerController.convertUrlToId(url).toString();

    if (videoId != _controller.metadata.videoId) {
      _controller.load(videoId);
    }

    return YoutubePlayerIFramePlus(
      controller: _controller,
      aspectRatio: 16 / 9,
    );
  }

  void deleteProject() async {
    final docId = await FirebaseFirestore.instance
        .collection('aiditor_projects')
        .where('project_id', isEqualTo: widget.projectId)
        .get()
        .then((value) => value.docs.first.id);

    await FirebaseFirestore.instance
        .collection('aiditor_projects')
        .doc(docId)
        .delete();
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
                    margin: EdgeInsets.all(40),
                    child: _buildVideo(_currentVideoUrl),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(40),
                    child: ListView.builder(
                      itemCount: projectVideos.length,
                      itemBuilder: (context, index) {
                        final videoData = projectVideos[index].data();
                        final videoUrl = videoData?['url'];
                        final videoName = videoData?['filename'];
                        return Card(
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                _currentVideoUrl = videoUrl ?? '';
                              });
                            },
                            title: Text(videoName ?? ''),
                            subtitle: Text(videoUrl ?? ''),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
