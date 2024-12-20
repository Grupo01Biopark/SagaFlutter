import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saga_flutter_app/pages/certificado/certificado.dart';
import 'package:saga_flutter_app/pages/dashboard/dashboard.dart';
import 'package:saga_flutter_app/pages/empresa/empresa.dart';
import 'package:saga_flutter_app/pages/checklists/checklists.dart';
import 'package:saga_flutter_app/pages/checklists/checklists_adicionar.dart';
import 'package:saga_flutter_app/pages/empresa/empresa_adicionar.dart';
import 'package:saga_flutter_app/pages/formulario/formulario.dart';
import 'package:saga_flutter_app/pages/formulario/formulario_cadastro.dart';
import 'package:saga_flutter_app/pages/formulario/formulario_iniciar.dart';
import 'package:saga_flutter_app/pages/login/tela_cadastro_user.dart';
import 'package:saga_flutter_app/pages/login/tela_login.dart';
import 'package:saga_flutter_app/pages/perguntas/pergunta.dart';
import 'package:saga_flutter_app/pages/perguntas/pergunta_adicionar.dart';
import 'package:saga_flutter_app/pages/user/user.dart';
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
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginPage(),
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
            '/checklists': (context) => MainScaffold(
                  body: ChecklistPage(),
                  title: 'Checklists',
                ),
            '/checklists/adicionar': (context) => MainScaffold(
                  body: AddChecklistPage(),
                  title: 'Empresa',
                ),
            '/formularios/listagem': (context) => MainScaffold(
                  body: FormularioPage(),
                  title: 'Formulários',
                ),
            '/formularios/cadastro': (context) => MainScaffold(
                  body: FormularioCadastroPage(),
                  title: 'Formulários',
                ),
            '/certificado': (context) => MainScaffold(
                  body: CertificadoPage(),
                  title: "Certificados",
                ),
            '/usuario': (context) => MainScaffold(
                  body: UsuarioPage(),
                  title: "Usuarios",
                ),
            '/usuario/cadastro': (context) => MainScaffold(
                  body: RegistrationUser(),
                  title: "Usuarios",
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
