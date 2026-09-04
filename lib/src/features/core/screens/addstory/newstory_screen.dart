import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:codeverse/src/constants/colors.dart';
import 'package:codeverse/src/constants/sizes.dart';
import 'package:codeverse/src/features/core/screens/addstory/story_screen.dart';
import 'package:codeverse/src/repository/user_repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

String get kApiBaseUrl {
  if (Platform.isAndroid) return 'http://10.0.2.2:5000';
  return 'http://127.0.0.1:5000';
}

class NewstoryScreen extends StatefulWidget {
  const NewstoryScreen({Key? key}) : super(key: key);

  @override
  _NewstoryScreenState createState() => _NewstoryScreenState();
}

class _NewstoryScreenState extends State<NewstoryScreen>
    with TickerProviderStateMixin {
  String? _selectedConcept;
  String? _selectedStoryGenre;
  bool _isLoading = false;

  final PageController _pageController = PageController();
  double _progress = 0.0;

  static const int _pagesCount = 2;
  int _currentPage = 0;

  late AnimationController _animationController;
  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;

  // ------------------------------------------------------------------
  // API call
  // ------------------------------------------------------------------

  Future<void> _generateStory() async {
    setState(() => _isLoading = true);

    final userEmail = Get.find<UserRepository>().getLoggedInUserEmail();

    if (userEmail == null) {
      _showError('You need to be logged in to generate a story.');
      setState(() => _isLoading = false);
      return;
    }

    final requestData = {
      'concept': _selectedConcept,
      'genre': _selectedStoryGenre,
      'email': userEmail,
    };

    debugPrint('POST $kApiBaseUrl/generate_story');
    debugPrint('Body: $requestData');

    try {
      final response = await http
          .post(
            Uri.parse('$kApiBaseUrl/generate_story'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestData),
          )
          // Generation takes a while - four sequential model calls.
          .timeout(const Duration(seconds: 120));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('Generated in ${data['generation_time_seconds']}s');
        _navigateToStoryScreen(data);
      } else {
        String detail = 'Server returned ${response.statusCode}';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['error'] != null) detail = body['error'];
        } catch (_) {}
        _showError(detail);
      }
    } on TimeoutException {
      if (!mounted) return;
      _showError('The story took too long to generate. Please try again.');
    } catch (e) {
      if (!mounted) return;
      _showError('Could not reach the server. Check it is running and that '
          'the address is correct.\n\n$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  void _navigateToStoryScreen(Map<String, dynamic> data) {
    const genreImages = {
      'Adventure': 'assets/images/story/adventure.gif',
      'Fantasy': 'assets/images/story/fantasy.png',
      'Fairy Tales': 'assets/images/story/fairytale.png',
      'Mystery': 'assets/images/story/mystery.gif',
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryScreen(
          data: data,
          genreImage: genreImages[_selectedStoryGenre] ?? '',
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      if (_pageController.hasClients) {
        final page = _pageController.page;
        if (page != null) {
          setState(() {
            _progress = page / (_pagesCount - 1);
            _currentPage = page.round();
          });
        }
      }
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _arrowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);

    _arrowAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _arrowAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _arrowAnimationController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CVBackgroundColor,
      appBar: AppBar(
        backgroundColor: CVBackgroundColor,
        title: Text(
          'New Story',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: CVAccentColor2),
        ),
        centerTitle: true,
      ),
      body: _isLoading ? _buildLoadingView() : _buildQuestionFlow(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CVAccentColor),
          ),
          const SizedBox(height: 20),
          Text(
            'Almost done!',
            style: TextStyle(
              color: CVAccentColor2,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your story is on its way..',
            style: TextStyle(
              color: CVAccentColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'This can take up to a minute.',
            style: TextStyle(color: Colors.black38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionFlow() {
    return Column(
      children: [
        const SizedBox(height: 50),
        SizedBox(
          height: 8.0,
          width: 350.0,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progress,
                backgroundColor: CVAccentColor3,
                valueColor: AlwaysStoppedAnimation<Color>(CVAccentColor2),
              );
            },
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            children: [
              _buildQuestionPage(
                title:
                    'Which programming concept would you like to study today?',
                subtitle:
                    'Choose a concept you\'re interested in. Let\'s make learning fun and productive!',
                options: const [
                  'Sequence',
                  'Loops',
                  'Conditionals',
                  'Variables',
                ],
                groupValue: _selectedConcept,
                onChanged: (value) => setState(() => _selectedConcept = value),
                onNext: _goToNextPage,
              ),
              _buildQuestionPage(
                title: 'What\'s your favorite kind of story?',
                subtitle:
                    'Choose the type of story you love the most! This helps us find the best stories for you.',
                options: const [
                  'Adventure',
                  'Fantasy',
                  'Fairy Tales',
                  'Mystery',
                ],
                groupValue: _selectedStoryGenre,
                onChanged: (value) =>
                    setState(() => _selectedStoryGenre = value),
                onNext: _onSubmit,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onSubmit() {
    if (_selectedConcept != null && _selectedStoryGenre != null) {
      _generateStory();
    } else {
      _showError('Please complete all questions before proceeding.');
    }
  }

  Widget _buildQuestionPage({
    required String title,
    required String subtitle,
    required List<String> options,
    required String? groupValue,
    required void Function(String?) onChanged,
    required VoidCallback onNext,
  }) {
    return Padding(
      padding: const EdgeInsets.all(CVDefaultSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: CVAccentColor2,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.black38, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ...options.map((option) {
            return ListTile(
              title: Text(option),
              leading: Radio<String>(
                value: option,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: CVAccentColor2,
              ),
            );
          }),
          const SizedBox(height: 32),
          // Arrow on every page except the last; button on the last page.
          if (_currentPage < _pagesCount - 1)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onNext,
                child: AnimatedBuilder(
                  animation: _arrowAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_arrowAnimation.value, 0),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: CVAccentColor,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CVAccentColor2,
                  shape: const StadiumBorder(),
                ),
                child: const Center(
                  child: Text(
                    'Generate Your Story',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
