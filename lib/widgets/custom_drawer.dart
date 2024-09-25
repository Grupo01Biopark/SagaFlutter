import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saga_flutter_app/pages/user/user_provider.dart';

class CustomDrawer extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  CustomDrawer({required this.isDarkMode, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(user?.name ?? 'Nome do Usuário'),
            accountEmail: Text(user?.email ?? 'email@exemplo.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage('URL_DA_FOTO_DO_USUARIO'),
            ),
            decoration: BoxDecoration(
              color: Color(0xFF0F6FC6),
            ),
            otherAccountsPictures: <Widget>[
              IconButton(
                icon: Icon(
                  isDarkMode ? Icons.nights_stay : Icons.wb_sunny,
                  color: Colors.white,
                ),
                onPressed: () {
                  onThemeChanged(!isDarkMode);
                },
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/dashboard');
            },
          ),
          ExpansionTile(
            leading: Icon(Icons.question_answer),
            title: Text('Perguntas'),
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.list),
                title: Text('Listar Perguntas'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/pergunta');
                },
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: Text('Cadastrar Pergunta'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/pergunta/adicionar');
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.business),
            title: Text('Empresas'),
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.list),
                title: Text('Listar Empresas'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/empresa');
                },
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: Text('Cadastrar Empresa'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/empresa/adicionar');
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.check_box),
            title: Text('Checklists'),
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.list),
                title: Text('Listar Checklists'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/checklists/list');
                },
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: Text('Cadastrar Checklist'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/checklists/add');
                },
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Formulários'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/formularios');
            },
          ),
          ListTile(
            leading: Icon(Icons.verified),
            title: Text('Certificados'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/certificado');
            },
          ),
        ],
      ),
    );
  }
}