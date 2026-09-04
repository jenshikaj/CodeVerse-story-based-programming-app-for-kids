import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String phoneNo;
  final String password;
  String? profileImage;
  final DateTime createdAt;
  int score;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNo,
    required this.password,
    this.profileImage,
    required this.createdAt,
    this.score = 0,
  });

  toJson() {
    return {
      "FullName": fullName,
      "Email": email,
      "Phone": phoneNo,
      "Password": password,
      "ProfileImage": profileImage,
      "CreatedAt": createdAt,
      "Score": score,
    };
  }

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return UserModel(
      id: document.id,
      email: data?["Email"],
      password: data?["Password"],
      fullName: data?["FullName"],
      phoneNo: data?["Phone"],
      profileImage: data?["ProfileImage"],
      createdAt: (data?["CreatedAt"] as Timestamp).toDate(),
      score: data?["Score"] ?? 0,
    );
  }
}
