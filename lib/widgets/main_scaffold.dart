import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import 'custom_drawer.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;
  final String title;

  const MainScaffold({Key? key, required this.body, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: CustomDrawer(
        isDarkMode: themeNotifier.isDarkMode,
        onThemeChanged: (isDark) {
          themeNotifier.toggleTheme();
        },
      ),
      body: body,
    );
  }
}
