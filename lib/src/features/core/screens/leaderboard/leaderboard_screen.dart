import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:codeverse/src/constants/colors.dart';
import 'package:codeverse/src/utils/image_helper.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final Future<QuerySnapshot> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture =
        _firestore.collection('Users').orderBy('Score', descending: true).get();
  }

  static T? _field<T>(QueryDocumentSnapshot doc, String key) {
    final data = doc.data();
    if (data is Map<String, dynamic> && data.containsKey(key)) {
      final value = data[key];
      if (value is T) return value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = _auth.currentUser?.email;

    return Scaffold(
      backgroundColor: CVBackgroundColor,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              "assets/images/leaderboard.png",
              fit: BoxFit.cover,
            ),
          ),

          // Leaderboard title
          const Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Leaderboard",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CVPrimaryColor,
                ),
              ),
            ),
          ),

          // Top 3 ranks on the image
          FutureBuilder<QuerySnapshot>(
            future: _leaderboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Could not load the leaderboard.",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No users found!",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              final users = snapshot.data!.docs;

              return Stack(
                children: [
                  if (users.isNotEmpty)
                    Positioned(
                      top: 120,
                      left: MediaQuery.of(context).size.width / 2 - 45,
                      child: _rank(
                        radius: 45.0,
                        image: _field<String>(users[0], 'ProfileImage'),
                        name: _field<String>(users[0], 'FullName') ?? 'Unknown',
                        point: (_field<int>(users[0], 'Score') ?? 0).toString(),
                        rank: 1,
                      ),
                    ),
                  if (users.length > 1)
                    Positioned(
                      top: 200,
                      left: 60,
                      child: _rank(
                        radius: 30.0,
                        image: _field<String>(users[1], 'ProfileImage'),
                        name: _field<String>(users[1], 'FullName') ?? 'Unknown',
                        point: (_field<int>(users[1], 'Score') ?? 0).toString(),
                        rank: 2,
                      ),
                    ),
                  if (users.length > 2)
                    Positioned(
                      top: 200,
                      right: 60,
                      child: _rank(
                        radius: 30.0,
                        image: _field<String>(users[2], 'ProfileImage'),
                        name: _field<String>(users[2], 'FullName') ?? 'Unknown',
                        point: (_field<int>(users[2], 'Score') ?? 0).toString(),
                        rank: 3,
                      ),
                    ),
                ],
              );
            },
          ),

          // Remaining users
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              decoration: const BoxDecoration(
                color: CVBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: FutureBuilder<QuerySnapshot>(
                future: _leaderboardFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.length <= 3) {
                    return const Center(child: Text("No additional users."));
                  }

                  final otherUsers = snapshot.data!.docs.skip(3).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: otherUsers.length,
                    itemBuilder: (context, index) {
                      final user = otherUsers[index];
                      final isCurrentUser =
                          _field<String>(user, 'Email') == currentUserEmail;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.grey[200] : null,
                          border: isCurrentUser
                              ? Border.all(color: CVAccentColor2, width: 2)
                              : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              (index + 4).toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            CircleAvatar(
                              radius: 25,
                              // Handles base64, legacy http URLs, and null.
                              backgroundImage: profileImageProvider(
                                _field<String>(user, 'ProfileImage'),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                _field<String>(user, 'FullName') ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              height: 25,
                              width: 70,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    (_field<int>(user, 'Score') ?? 0)
                                        .toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rank({
    required double radius,
    required String? image,
    required String name,
    required String point,
    int? rank,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: radius,
                  // Handles base64, legacy http URLs, and null.
                  backgroundImage: profileImageProvider(image),
                ),
                if (rank != null)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          rank.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                point,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
