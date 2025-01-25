import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/bloc/chat_cubit/chat_cubit.dart';
import 'package:oratio_app/popup_notification/popup_notification.dart';
import 'package:oratio_app/ui/screens/chat_screen.dart';
import 'package:oratio_app/ui/screens/feeds_page.dart';
import 'package:oratio_app/ui/pages/home_screen.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final GlobalKey<FeedsListScreenState> _feedsListScreenKey;
  final GlobalKey<HomeScreenState> _homeScreenKey;

  _HomePageState()
      : _feedsListScreenKey = GlobalKey<FeedsListScreenState>(),
        _homeScreenKey = GlobalKey<HomeScreenState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    PopupNotification.initialize(context);
    _pages = [
      FeedsListScreen(key: _feedsListScreenKey),
      HomeScreen(key: _homeScreenKey),
      const ChatScreen(),
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      if (index == 0) {
        _feedsListScreenKey.currentState?.scrollToTop();
      } else if (index == 1) {
        _homeScreenKey.currentState?.scrollToTop();
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (x, y) {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      canPop: _selectedIndex == 0,
      child: Scaffold(
        backgroundColor: _selectedIndex == 2 ? Colors.white : AppColors.gray,
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            const BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.rss), label: 'Feeds'),
            const BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.wallet), label: 'Wallet'),
            BottomNavigationBarItem(
                icon: Badge(
                    isLabelVisible:
                        context.read<ChatCubit>().unreadCount(true) > 0,
                    label: context.read<ChatCubit>().unreadCount(true) > 0
                        ? Text(context
                            .watch<ChatCubit>()
                            .unreadCount(true)
                            .toString())
                        : null,
                    child: const Icon(FontAwesomeIcons.solidMessage)),
                label: 'Check Up'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor:
              AppColors.primary, // Change the selected item color
          unselectedItemColor: Colors.grey, // Change the unselected item color
          backgroundColor: Colors.white, // Change the background color
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
