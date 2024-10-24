import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oratio_app/ui/screens/chat_screen.dart';
import 'package:oratio_app/ui/screens/feeds_page.dart';
import 'package:oratio_app/ui/pages/home_screen.dart';
import 'package:oratio_app/ui/pages/settings_screen.dart';
import 'package:oratio_app/ui/themes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _pages = <Widget>[
    const HomeScreen(),
    const FeedsListScreen(),
    ChatScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedIndex == 2 ? Colors.white : AppColors.gray,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.wallet), label: 'Wallet'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.rss), label: 'Feeds'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.solidMessage), label: 'Check Up'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary, // Change the selected item color
        unselectedItemColor: Colors.grey, // Change the unselected item color
        backgroundColor: Colors.white, // Change the background color
        onTap: (id) {
          setState(() {
            _selectedIndex = id;
          });
        },
      ),
    );
  }
}
