import 'package:flutter/material.dart';
import 'package:oratio_app/ui/screens/home_screen.dart';
import 'package:oratio_app/ui/themes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray,
      body: HomeScreen(),
    );
  }
}
