import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:codeverse/src/constants/image_strings.dart';

ImageProvider profileImageProvider(String? stored) {
  if (stored == null || stored.isEmpty) {
    return const AssetImage(CVProfileImage);
  }
  if (stored.startsWith('http')) {
    return NetworkImage(stored);
  }
  try {
    return MemoryImage(base64Decode(stored));
  } catch (_) {
    return const AssetImage(CVProfileImage);
  }
}
