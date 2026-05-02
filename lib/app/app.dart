import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gamify Photography',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: getRouter(initialRoute),
    );
  }
}

