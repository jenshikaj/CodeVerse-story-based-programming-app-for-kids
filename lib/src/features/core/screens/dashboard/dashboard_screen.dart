import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:codeverse/src/constants/colors.dart';
import 'package:codeverse/src/constants/sizes.dart';
import 'package:codeverse/src/features/core/screens/dashboard/category_stories_screen.dart';
import 'package:codeverse/src/features/core/screens/dashboard/story_categories.dart';
import 'package:codeverse/src/features/core/screens/profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final textTheme = Theme.of(context).textTheme;
    final email = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      backgroundColor: CVBackgroundColor,
      appBar: AppBar(
        backgroundColor: CVBackgroundColor,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: textTheme.headlineSmall?.copyWith(color: CVAccentColor2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_sharp, color: CVAccentColor2),
            onPressed: () => Get.to(
              () => const ProfileScreen(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 800),
            ),
          ),
        ],
      ),
      body: email == null
          ? _message('You need to be signed in to see your stories.')
          : _buildBody(email, textTheme),
    );
  }

  Widget _buildBody(String email, TextTheme textTheme) {
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
          debugPrint('Dashboard query failed: ${snapshot.error}');
          return _message('Could not load your stories.\n\n${snapshot.error}');
        }

        final docs = snapshot.data?.docs ?? [];

        final counts = <String, int>{};
        for (final doc in docs) {
          final concept = _field<String>(doc, 'concept');
          if (concept == null) continue;
          final key = concept.toLowerCase();
          counts[key] = (counts[key] ?? 0) + 1;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            CVDefaultSize,
            8,
            CVDefaultSize,
            CVDefaultSize,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Stories',
                style: textTheme.headlineSmall?.copyWith(
                  color: CVSecondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                docs.isEmpty
                    ? 'Pick a concept and tap + to write your first story.'
                    : '${docs.length} ${docs.length == 1 ? "story" : "stories"} across four concepts',
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 40),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.65,
                children: [
                  for (final category in kStoryCategories)
                    _CategoryCard(
                      category: category,
                      count: counts[category.name.toLowerCase()] ?? 0,
                      onTap: () => Get.to(
                        () => CategoryStoriesScreen(category: category),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 400),
                      ),
                    ),
                ],
              ),
            ],
          ),
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.count,
    required this.onTap,
  });

  final StoryCategory category;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: category.color.withOpacity(0.4),
      color: category.color,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        child: Stack(
          children: [
            Positioned(
              right: -18,
              bottom: -18,
              child: Icon(
                category.icon,
                size: 96,
                color: Colors.white.withOpacity(0.16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(category.icon, color: Colors.white, size: 22),
                  ),
                  const Spacer(),
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.blurb,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11.5,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      count == 0
                          ? 'No stories'
                          : '$count ${count == 1 ? "story" : "stories"}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
