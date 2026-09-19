import 'package:flutter/material.dart';
import 'package:flutter_todo/features/router.dart';

Color currentAppTheme = const Color(0xFF1EC4B6);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
