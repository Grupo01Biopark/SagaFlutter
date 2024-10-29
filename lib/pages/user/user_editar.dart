import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditUserPage extends StatefulWidget {
  final int userId; // Recebe o ID do usuário para ser editado

  EditUserPage({required this.userId});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Carrega os dados do usuário para edição
  }

  Future<void> _fetchUserData() async {
    final response = await http.get(Uri.parse(
        "http://186.226.48.222:8080/usuarios/listar/${widget.userId}"));

    if (response.statusCode == 200) {
      var utf8Response = utf8.decode(response.bodyBytes);
      var userData = json.decode(utf8Response);

      setState(() {
        _nameController.text = userData['user']['name'];
        _emailController.text = userData['user']['email'];
      });
    } else {
      throw Exception('Falha ao carregar dados do usuário');
    }
  }

  Future<void> _editUser() async {
    if (_formKey.currentState!.validate()) {
      final apiUrl =
          "http://186.226.48.222:8080/usuarios/editar/${widget.userId}";

      Map<String, dynamic> userData = {
        "name": _nameController.text,
        "email": _emailController.text,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário editado com sucesso!')),
        );
        Navigator.of(context).pushReplacementNamed('/usuario');
      } else {
        var utf8Response = utf8.decode(response.bodyBytes);
        var responseJson = json.decode(utf8Response);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseJson['message'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                    labelText: 'Nome', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _editUser,
                child: Text(
                  'Editar Usuário',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F6FC6),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: EditUserPage(userId: 1), // Passe o ID do usuário para edição
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
