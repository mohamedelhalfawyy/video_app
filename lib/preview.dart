import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PreviewPage extends StatefulWidget {
  final String videoId;
  final String videoName;
  final String title;
  final String description;

  const PreviewPage({super.key,
    required this.videoId,
    required this.videoName,
    required this.title,
    required this.description,
  });

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.videoName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Theme.of(context).accentColor,
                progressColors: ProgressBarColors(
                  playedColor: Theme.of(context).accentColor,
                  handleColor: Theme.of(context).accentColor,
                ),
                onReady: () {},
                onEnded: (data) {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Title: ${widget.title}',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 15.0),
                  Text(
                    "Description:",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.description,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
