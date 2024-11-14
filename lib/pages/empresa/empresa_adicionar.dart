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
  final TextEditingController _emailController =
      TextEditingController(); // Controlador para o campo de e-mail

  String _selectedPorte = ""; // Variável para armazenar a seleção de Porte
  String _selectedSetor = ""; // Variável para armazenar a seleção de Setor

  List<dynamic> portes = [];
  List<dynamic> setores = [];

  @override
  void initState() {
    super.initState();
    _fetchPortesSetores();
  }

  Future<void> _fetchPortesSetores() async {
    final response =
        await http.get(Uri.parse("http://138.186.234.48:8080/empresas/listar"));
    if (response.statusCode == 200) {
      setState(() {
        var utf8Response = utf8.decode(response.bodyBytes);
        var decodedData = json.decode(utf8Response);
        portes = decodedData['portes'];
        setores = decodedData['setores'];
      });
    } else {
      throw Exception('Falha ao carregar portes');
    }
  }

  Future<void> _addEmpresa() async {
    if (_formKey.currentState!.validate()) {
      final apiUrl = "http://138.186.234.48:8080/empresas/adicionar";

      Map<String, dynamic> empresaData = {
        "nomeFantasia": _nomeFantasiaController.text,
        "cnpj": _cnpjController.text,
        "razaoSocial": _razaoSocialController.text,
        "email": _emailController.text, // Incluindo o campo de e-mail
        "logradouro": _logradouroController.text,
        "numero": _numeroController.text,
        "cep": _cepController.text,
        "complemento": _complementoController.text,
        "porte": {
          "id": int.parse(_selectedPorte),
        },
        "setor": {
          "id": int.parse(_selectedSetor),
        }
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(empresaData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Empresa adicionada com sucesso!')),
        );
        Navigator.of(context).pushReplacementNamed('/empresa');
      } else {
        var responseJson = json.decode(response.body);
        print(responseJson);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseJson['error'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                decoration: InputDecoration(
                    labelText: 'CNPJ', border: OutlineInputBorder()),
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
                decoration: InputDecoration(
                    labelText: 'Razão Social', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a razão social';
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
                    return 'Por favor, insira o e-mail';
                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Por favor, insira um e-mail válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _logradouroController,
                decoration: InputDecoration(
                    labelText: 'Logradouro', border: OutlineInputBorder()),
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
                decoration: InputDecoration(
                    labelText: 'Número', border: OutlineInputBorder()),
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
                decoration: InputDecoration(
                    labelText: 'CEP', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CEP';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: null,
                decoration: InputDecoration(
                  labelText: 'Porte',
                  border: OutlineInputBorder(),
                ),
                items: portes.map<DropdownMenuItem<String>>((dynamic porte) {
                  return DropdownMenuItem<String>(
                    value: '${porte['id'].toString()}',
                    child: Text(porte['titulo']),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedPorte = value.toString();
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o porte da empresa';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: null,
                decoration: InputDecoration(
                  labelText: 'Setor',
                  border: OutlineInputBorder(),
                ),
                items: setores.map<DropdownMenuItem<String>>((dynamic setor) {
                  return DropdownMenuItem<String>(
                    value: '${setor['id'].toString()}',
                    child: Text(setor['titulo']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSetor = value.toString();
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o setor da empresa';
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
    home: AddEmpresaPage(),
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
