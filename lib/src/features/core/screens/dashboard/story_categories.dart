import 'package:flutter/material.dart';

class StoryCategory {
  final String name;
  final String blurb;
  final IconData icon;
  final Color color;

  const StoryCategory({
    required this.name,
    required this.blurb,
    required this.icon,
    required this.color,
  });
}

const List<StoryCategory> kStoryCategories = [
  StoryCategory(
    name: 'Sequence',
    blurb: 'Step by step, in order',
    icon: Icons.format_list_numbered_rounded,
    color: Color(0xFF10517B),
  ),
  StoryCategory(
    name: 'Loops',
    blurb: 'Doing Repeatedly',
    icon: Icons.loop_rounded,
    color: Color(0xFFC77D3A),
  ),
  StoryCategory(
    name: 'Conditionals',
    blurb: 'Choosing what happens next',
    icon: Icons.call_split_rounded,
    color: Color(0xFF7B5EA7),
  ),
  StoryCategory(
    name: 'Variables',
    blurb: 'Keeping track of things',
    icon: Icons.inventory_2_rounded,
    color: Color(0xFF2E8B96),
  ),
];

StoryCategory? categoryByName(String? name) {
  if (name == null) return null;
  for (final c in kStoryCategories) {
    if (c.name.toLowerCase() == name.toLowerCase()) return c;
  }
  return null;
}

const int kStoryImageCount = 20;

String storyImageFor(String storyId) {
  final index = storyId.hashCode.abs() % kStoryImageCount;
  return 'assets/images/story/story${index + 1}.png';
}
