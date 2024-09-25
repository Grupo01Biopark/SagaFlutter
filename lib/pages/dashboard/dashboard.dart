import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false,
        title: Text('Dashboard'),
      ),
      body: Center(
        child: Text('Bem-vindo ao SAGssA!'),
      ),
    );
  }
}


void main() {
  runApp(MaterialApp(
    home: DashboardPage(),
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}