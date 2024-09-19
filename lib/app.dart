import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saga_flutter_app/pages/certificado/certificado.dart';
import 'package:saga_flutter_app/pages/dashboard/dashboard.dart';
import 'package:saga_flutter_app/pages/empresa/empresa.dart';
import 'package:saga_flutter_app/pages/empresa/empresa_adicionar.dart';
import 'package:saga_flutter_app/pages/formulario/formulario.dart';
import 'package:saga_flutter_app/pages/formulario/formulario_iniciar.dart';
import 'package:saga_flutter_app/pages/perguntas/pergunta.dart';
import 'package:saga_flutter_app/pages/perguntas/pergunta_adicionar.dart';
import 'package:saga_flutter_app/widgets/custom_scroll_behavior.dart';
import 'widgets/main_scaffold.dart';
import 'theme/theme_notifier.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'SAGA',
          scrollBehavior: MyCustomScrollBehavior(),
          debugShowCheckedModeBanner: false,
          theme: themeNotifier.currentTheme,
          initialRoute: '/dashboard',
          routes: {
            '/dashboard': (context) => MainScaffold(
                  body: DashboardPage(),
                  title: 'Dashboard',
                ),
            '/pergunta': (context) => MainScaffold(
                  body: PerguntaPage(),
                  title: 'Pergunta',
                ),
            '/pergunta/adicionar': (context) => MainScaffold(
                  body: AddPerguntaPage(),
                  title: 'Pergunta',
                ),
            '/empresa': (context) => MainScaffold(
                  body: EmpresaPage(),
                  title: 'Empresa',
                ),
            '/empresa/adicionar': (context) => MainScaffold(
                  body: AddEmpresaPage(),
                  title: 'Empresa',
                ),
            '/forms': (context) => MainScaffold(
                  body: FormularioPage(),
                  title: 'Formulários',
                ),
            '/forms/iniciar': (context) => MainScaffold(
                  body: FormularioIniciarPage(),
                  title: 'Iniciar Formulário',
                ),
            '/certificado': (context) => MainScaffold(
                  body: CertificadoPage(),
                  title: "Certificados",
                )
          },

        );
      },
    );
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
}