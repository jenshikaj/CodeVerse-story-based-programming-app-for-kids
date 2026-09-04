import 'package:codeverse/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class StoryDetailScreen extends StatefulWidget {
  final String storyTitle;
  final String storyContent;
  final String storyImage;

  const StoryDetailScreen({
    Key? key,
    required this.storyTitle,
    required this.storyContent,
    required this.storyImage,
  }) : super(key: key);

  @override
  _StoryDetailScreenState createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    flutterTts.setStartHandler(() {
      setState(() {
        isSpeaking = true;
        isPaused = false;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
        isPaused = false;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        isPaused = true;
        isSpeaking = false;
      });
    });

    flutterTts.setErrorHandler((error) {
      setState(() {
        isSpeaking = false;
        isPaused = false;
      });
      print("TTS Error: $error");
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> toggleSpeak() async {
    if (isSpeaking) {
      if (isPaused) {
        await flutterTts.stop();
        setState(() {
          isPaused = false;
          isSpeaking = false;
        });
      } else {
        await flutterTts.pause();
      }
    } else {
      await flutterTts.speak('${widget.storyTitle}. ${widget.storyContent}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CVBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Story',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: CVAccentColor,
              ),
        ),
        centerTitle: true,
        backgroundColor: CVBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  widget.storyImage,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.storyTitle,
                style: TextStyle(
                  color: CVAccentColor2,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(widget.storyContent,
                  style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleSpeak,
        child: Icon(
          isSpeaking
              ? (isPaused ? Icons.play_arrow : Icons.pause)
              : Icons.volume_up,
        ),
        backgroundColor: CVAccentColor3,
      ),
    );
  }
}
