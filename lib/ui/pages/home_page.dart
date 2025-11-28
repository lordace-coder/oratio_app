import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oratio_app/bloc/chat_cubit/chat_cubit.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:oratio_app/popup_notification/popup_notification.dart';
import 'package:oratio_app/services/app_update_service.dart';
import 'package:oratio_app/ui/screens/chat_screen.dart';
import 'package:oratio_app/ui/screens/feeds_page.dart';
import 'package:oratio_app/ui/screens/home_screen.dart';
import 'package:oratio_app/ui/themes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  _HomePageState();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // check for just android
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        AppUpdateService().checkPlayStoreUpdate();
      }
    });
    PopupNotification.initialize(context);
    _pages = [
      const FeedsListScreen(),
      const HomeScreen(),
      const ChatScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int unreadchats = 0;

    if (context.watch<ChatCubit>().state is ChatsLoaded) {
      final chatsState = context.watch<ChatCubit>().state as ChatsLoaded;
      unreadchats =
          chatsState.chats.fold(0, (sum, chat) => sum + chat.unreadCount);
    }

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
                icon: Icon(FontAwesomeIcons.bars), label: 'Menu'),
            BottomNavigationBarItem(
                // Temporarily disabled - backend needs update
                icon: Badge(
                    isLabelVisible: false, // unreadchats > 0,
                    label:
                        unreadchats > 0 ? Text(unreadchats.toString()) : null,
                    child: const Icon(FontAwesomeIcons.solidMessage)),
                label: 'Check Up'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
