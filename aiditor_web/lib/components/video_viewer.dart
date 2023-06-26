import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoViewer extends StatefulWidget {
  final String url;

  VideoViewer(this.url);

  @override
  _VideoViewerState createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final double width = 9000;
    double aspectRatio =
        _controller.value.isInitialized ? _controller.value.aspectRatio : 1.0;
    if (aspectRatio.isNaN) aspectRatio = 1.0;
    return Container(
      width: width,
      height: width / aspectRatio,
      child: Stack(children: [
        _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Center(child: CircularProgressIndicator()),
        Container(
            alignment: Alignment.bottomCenter,
            child: ButtonBar(
              children: <Widget>[
                IconButton(
                  icon: Icon(_controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow),
                  color: Colors.blue,
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                ),
              ],
            ))
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}