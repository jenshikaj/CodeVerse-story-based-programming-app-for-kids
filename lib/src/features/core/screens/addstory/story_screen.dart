import 'package:codeverse/src/constants/colors.dart';
import 'package:codeverse/src/features/core/screens/addstory/question_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class StoryScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String genreImage;

  const StoryScreen({
    Key? key,
    required this.data,
    required this.genreImage,
  }) : super(key: key);

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _setupTtsHandlers();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
  }

  void _setupTtsHandlers() {
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

  Future<void> _toggleSpeak(String text) async {
    if (isSpeaking) {
      if (isPaused) {
        await flutterTts.stop();
      } else {
        await flutterTts.pause();
      }
    } else {
      await flutterTts.speak(text);
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.data['title'] ?? 'No Title';
    final story = widget.data['story'] ?? 'No Story Available';
    final List<String> questions = (widget.data['questions'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ??
        [];
    final List<List<Map<String, String>>> options =
        (widget.data['options'] as List<dynamic>?)?.map((item) {
              if (item is Map) {
                return [item.cast<String, String>()];
              }
              return <Map<String, String>>[];
            }).toList() ??
            [];
    final List<String> correctAnswers =
        (widget.data['correct_answers'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            [];

    final List<String> hints = (widget.data['hints'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: CVBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.genreImage.isNotEmpty)
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Image.asset(
                  widget.genreImage,
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: CVAccentColor,
                              ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      story,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
                _toggleSpeak('$title. $story');
              },
              child: Icon(
                isSpeaking
                    ? (isPaused ? Icons.play_arrow : Icons.pause)
                    : Icons.volume_up,
              ),
              backgroundColor: CVAccentColor,
              heroTag: 'speak',
            ),
          ),
          Positioned(
            right: 80,
            bottom: 2,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QuestionScreen(
                            questions: questions,
                            options: options,
                            correctAnswers: correctAnswers,
                            hints: hints,
                          )),
                );
              },
              child: Icon(Icons.quiz_sharp),
              backgroundColor: Colors.orangeAccent,
              heroTag: 'challenge',
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, String> extractHints(String hintString) {
  final hintsMap = <String, String>{};
  final hintParts = hintString.split(RegExp(r'\*\*Question \d+:\*\*'));

  for (int i = 1; i < hintParts.length; i++) {
    final trimmedHint = hintParts[i].trim();
    hintsMap['Hint for Question $i'] = trimmedHint;
  }

  return hintsMap;
}
