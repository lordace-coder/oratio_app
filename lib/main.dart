import 'package:flutter/material.dart';
import 'package:oratio_app/ui/routes/routes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Oratio Afrika',
      color: Colors.red,
      routerConfig: appRouter,
      theme: ThemeData(fontFamily: 'Itim'),
    );
  }
}
