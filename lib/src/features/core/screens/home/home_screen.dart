import 'dart:io';

import 'package:codeverse/src/constants/colors.dart';
import 'package:codeverse/src/features/core/screens/dashboard/dashboard_screen.dart';
import 'package:codeverse/src/features/core/screens/leaderboard/leaderboard_screen.dart';
import 'package:codeverse/src/features/core/screens/profile/profile_screen.dart';
import 'package:codeverse/src/features/core/screens/addstory/newstory_screen.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track the selected index
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const NewstoryScreen(),
    const LeaderboardScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else if (Platform.isIOS) {
                    exit(0);
                  }
                },
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: CVBackgroundColor,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: _screens,
        ),
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: CVBackgroundColor,
          onTap: _onItemTapped,
          index: _selectedIndex,
          items: const [
            Icon(
              Icons.home,
              color: CVAccentColor2,
            ),
            Icon(
              Icons.add,
              color: CVAccentColor2,
            ),
            Icon(
              Icons.leaderboard,
              color: CVAccentColor2,
            ),
          ],
        ),
      ),
    );
  }
}
