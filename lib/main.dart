import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './pages/login/tela_login.dart';
import './theme/theme_notifier.dart';

void main() {
  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: themeNotifier.currentTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginPage(),
          },
        );
      },
    );
  }
}
