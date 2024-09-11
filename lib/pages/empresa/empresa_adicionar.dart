import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddEmpresaPage extends StatefulWidget {
  @override
  _AddEmpresaPageState createState() => _AddEmpresaPageState();
}

class _AddEmpresaPageState extends State<AddEmpresaPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto
  final TextEditingController _nomeFantasiaController = TextEditingController();
  final TextEditingController _cnpjController = TextEditingController();
  final TextEditingController _razaoSocialController = TextEditingController();
  final TextEditingController _logradouroController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _porteController = TextEditingController();
  final TextEditingController _setorController = TextEditingController();

  Future<void> _addEmpresa() async {
    if (_formKey.currentState!.validate()) {
      final apiUrl = "http://127.0.0.1:8080/empresas/adicionar";

      Map<String, dynamic> empresaData = {
        "nomeFantasia": _nomeFantasiaController.text,
        "cnpj": _cnpjController.text,
        "razaoSocial": _razaoSocialController.text,
        "logradouro": _logradouroController.text,
        "numero": _numeroController.text,
        "cep": _cepController.text,
        "complemento": _complementoController.text,
        "porte": {
          "id": _porteController.text,
        },
        "setor": {
          "id": _setorController.text,
        }
      };

      // Realizar a requisição POST para a API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(empresaData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Exibir mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Empresa adicionada com sucesso!')),
        );
        Navigator.pop(context); // Retorna para a tela anterior
      } else {
        print(response.body);
        // Exibir mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar empresa')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Empresa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeFantasiaController,
                decoration: InputDecoration(
                    labelText: 'Nome Fantasia', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome fantasia';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _cnpjController,
                decoration: InputDecoration(labelText: 'CNPJ', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CNPJ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _razaoSocialController,
                decoration: InputDecoration(labelText: 'Razão Social', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a razão social';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _logradouroController,
                decoration: InputDecoration(labelText: 'Logradouro', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o logradouro';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _numeroController,
                decoration: InputDecoration(labelText: 'Número', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o número';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _cepController,
                decoration: InputDecoration(labelText: 'CEP', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CEP';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _complementoController,
                decoration:
                    InputDecoration(labelText: 'Complemento (opcional)', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _porteController,
                decoration: InputDecoration(labelText: 'Porte'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o porte da empresa';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _setorController,
                decoration: InputDecoration(labelText: 'Setor'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o setor da empresa';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addEmpresa,
                child: Text(
                  'Adicionar Empresa',
                  style: TextStyle(
                    color: Colors.white, // Define o texto branco
                    fontSize: 20, // Tamanho da fonte opcional
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F6FC6),
                   // Cor do texto quando pressionado
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 22), // Padding do botão
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // Bordas arredondadas de 5px
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
    home: AddEmpresaPage(),
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
