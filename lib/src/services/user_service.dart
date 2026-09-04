import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserService extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateUserScore(int newScore) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print("No user logged in.");
        return;
      }

      final userEmail = user.email;
      if (userEmail == null) {
        print("User email not found.");
        return;
      }

      // Find the user document using email
      final userQuery = await _firestore
          .collection('Users')
          .where('Email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        print("Error updating score: User does not exist!");
        return;
      }

      final userDoc = userQuery.docs.first.reference;

      // Run transaction to update the score
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);

        if (!snapshot.exists) {
          throw Exception("User does not exist!");
        }

        final currentScore =
            snapshot.data()?['Score'] ?? 0; // Default to 0 if missing
        final updatedScore = currentScore + newScore;

        transaction.update(userDoc, {'Score': updatedScore});
      });

      print("Score updated successfully!");
    } catch (e) {
      print("Error updating score: $e");
    }
  }
}
