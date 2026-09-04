import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:codeverse/src/constants/colors.dart';
import 'package:codeverse/src/features/core/screens/dashboard/story_categories.dart';
import 'package:codeverse/src/features/core/screens/dashboard/storydetail_screen.dart';

class CategoryStoriesScreen extends StatelessWidget {
  const CategoryStoriesScreen({super.key, required this.category});

  final StoryCategory category;

  static T? _field<T>(DocumentSnapshot doc, String key) {
    final data = doc.data();
    if (data is Map<String, dynamic> && data.containsKey(key)) {
      final value = data[key];
      if (value is T) return value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      backgroundColor: CVBackgroundColor,
      appBar: AppBar(
        backgroundColor: category.color,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          category.name,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: email == null
                ? _message('You need to be signed in to see your stories.')
                : _buildList(email),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      color: category.color,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(category.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              category.blurb,
              style: TextStyle(
                color: Colors.white.withOpacity(0.92),
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(String email) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('stories')
          .where('email', isEqualTo: email)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('Category query failed: ${snapshot.error}');
          return _message('Could not load your stories.\n\n${snapshot.error}');
        }

        final stories = (snapshot.data?.docs ?? []).where((doc) {
          final concept = _field<String>(doc, 'concept');
          return concept?.toLowerCase() == category.name.toLowerCase();
        }).toList();

        if (stories.isEmpty) {
          return _message(
            'No ${category.name} stories yet.\n\n'
            'Tap the + button and choose ${category.name} to create one.',
          );
        }

        stories.sort((a, b) {
          final ta = _field<Timestamp>(a, 'created_at');
          final tb = _field<Timestamp>(b, 'created_at');
          if (ta == null && tb == null) return 0;
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta);
        });

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: stories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final story = stories[index];
            final title = _field<String>(story, 'title') ?? 'Untitled story';
            final content = _field<String>(story, 'story') ?? '';
            final genre = _field<String>(story, 'genre');
            final created = _field<Timestamp>(story, 'created_at');
            final image = storyImageFor(story.id);

            return _StoryTile(
              title: title,
              genre: genre,
              created: created?.toDate(),
              image: image,
              accent: category.color,
              onTap: () => Get.to(
                () => StoryDetailScreen(
                  storyTitle: title,
                  storyContent: content,
                  storyImage: image,
                ),
                transition: Transition.rightToLeft,
              ),
            );
          },
        );
      },
    );
  }

  Widget _message(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontSize: 15),
        ),
      ),
    );
  }
}

class _StoryTile extends StatelessWidget {
  const _StoryTile({
    required this.title,
    required this.genre,
    required this.created,
    required this.image,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String? genre;
  final DateTime? created;
  final String image;
  final Color accent;
  final VoidCallback onTap;

  String _relativeDate(DateTime d) {
    final days = DateTime.now().difference(d).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: accent.withOpacity(0.25),
                  child: Icon(Icons.auto_stories, color: accent, size: 32),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: CVSecondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (genre != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              genre!,
                              style: TextStyle(
                                fontSize: 11,
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (created != null)
                          Text(
                            _relativeDate(created!),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                Icons.chevron_right_rounded,
                color: accent.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
