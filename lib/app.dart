import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saga_flutter_app/pages/dashboard/dashboard.dart';
import 'package:saga_flutter_app/pages/formulario/formulario.dart';
import 'widgets/main_scaffold.dart';
import 'theme/theme_notifier.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: themeNotifier.currentTheme,
          initialRoute: '/dashboard',
          routes: {
            '/dashboard': (context) => MainScaffold(
                  body: DashboardPage(),
                  title: 'Dashboard',
                ),
            '/forms': (context) => MainScaffold(
                  body: FormularioPage(),
                  title: 'Formulario',
                ),
          },
        );
      },
    );
  }
}
