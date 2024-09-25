import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saga_flutter_app/pages/user/user_provider.dart';
import 'app.dart';
import 'theme/theme_notifier.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}