import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:codeverse/src/features/authentication/models/user_model.dart';

/// Firestore access for the Users and stories collections.
class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  static const _timeout = Duration(seconds: 20);

  String? getLoggedInUserEmail() => _auth.currentUser?.email;

  Future<void> createUser(UserModel user) async {
    try {
      await _db.collection("Users").add(user.toJson()).timeout(_timeout);
    } on FirebaseException catch (e) {
      if (kDebugMode) print('createUser failed: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied') {
        throw 'You do not have permission to save this profile.';
      }
      throw 'Could not save your profile. Please try again.';
    } catch (e) {
      if (kDebugMode) print('createUser failed: $e');
      throw 'Could not save your profile. Please try again.';
    }
  }

  /// Returns null when no profile document exists for this email.
  Future<UserModel?> getUserDetails(String email) async {
    try {
      final snapshot = await _db
          .collection("Users")
          .where("Email", isEqualTo: email)
          .limit(1)
          .get()
          .timeout(_timeout);

      if (snapshot.docs.isEmpty) return null;
      return UserModel.fromSnapshot(snapshot.docs.first);
    } on FirebaseException catch (e) {
      if (kDebugMode) print('getUserDetails failed: ${e.code} - ${e.message}');
      throw 'Could not load your profile. Please try again.';
    } catch (e) {
      if (kDebugMode) print('getUserDetails failed: $e');
      throw 'Could not load your profile. Please try again.';
    }
  }

  Future<List<UserModel>> allUsers() async {
    try {
      final snapshot = await _db.collection("Users").get().timeout(_timeout);
      return snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
    } catch (e) {
      if (kDebugMode) print('allUsers failed: $e');
      throw 'Could not load users. Please try again.';
    }
  }

  Future<void> updateUserRecord(UserModel user) async {
    if (user.id == null) throw 'Cannot update a profile without an id.';

    try {
      final docRef = _db.collection("Users").doc(user.id);
      final snapshot = await docRef.get().timeout(_timeout);

      if (!snapshot.exists) throw 'That profile no longer exists.';

      final data = user.toJson();
      data.removeWhere((key, value) => value == null);

      await docRef.update(data).timeout(_timeout);
    } on FirebaseException catch (e) {
      if (kDebugMode) print('updateUserRecord failed: ${e.code}');
      throw 'Could not update your profile. Please try again.';
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _db.collection('Users').doc(userId).delete().timeout(_timeout);
    } catch (e) {
      if (kDebugMode) print('deleteUser failed: $e');
      throw 'Could not delete the profile. Please try again.';
    }
  }

  /// Deletes every story belonging to an email address.
  Future<int> deleteStoriesForEmail(String email) async {
    try {
      final snapshot = await _db
          .collection('stories')
          .where('email', isEqualTo: email)
          .get()
          .timeout(_timeout);

      if (snapshot.docs.isEmpty) return 0;

      var deleted = 0;
      for (var i = 0; i < snapshot.docs.length; i += 400) {
        final chunk = snapshot.docs.skip(i).take(400);
        final batch = _db.batch();
        for (final doc in chunk) {
          batch.delete(doc.reference);
        }
        await batch.commit().timeout(_timeout);
        deleted += chunk.length;
      }

      if (kDebugMode) print('Deleted $deleted stories for $email');
      return deleted;
    } catch (e) {
      if (kDebugMode) print('deleteStoriesForEmail failed: $e');
      throw 'Could not delete your stories. Please try again.';
    }
  }
}
