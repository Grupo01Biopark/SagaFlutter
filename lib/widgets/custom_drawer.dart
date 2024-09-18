import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  CustomDrawer({required this.isDarkMode, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('Nome do Usuário'),
            accountEmail: Text('email@exemplo.com'),
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
          ListTile(
            leading: Icon(Icons.question_answer),
            title: Text('Perguntas'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/questions');
            },
          ),
          ExpansionTile(
            leading: Icon(Icons.business),
            title: Text('Empresas'),
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.list),
                title: Text('Listar Empresas'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/empresa/list');
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
              Navigator.of(context).pushReplacementNamed('/forms');
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
