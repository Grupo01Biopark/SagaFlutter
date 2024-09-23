import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditEmpresaPage extends StatefulWidget {
  final int id; // Parâmetro para edição de empresa, agora obrigatório

  EditEmpresaPage(
      {required this.id}); // Construtor que agora requer um id obrigatório

  @override
  _EditEmpresaPageState createState() => _EditEmpresaPageState();
}

class _EditEmpresaPageState extends State<EditEmpresaPage> {
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
      TextEditingController(); // Novo campo de e-mail

  String _selectedPorte = ""; // Variável para armazenar a seleção de Porte
  String _selectedSetor = ""; // Variável para armazenar a seleção de Setor

  List<dynamic> portes = [];
  List<dynamic> setores = [];

  @override
  void initState() {
    super.initState();
    _fetchPortesSetores();
    _fetchEmpresaData(widget.id); // Buscar dados da empresa ao inicializar
  }

  Future<void> _fetchPortesSetores() async {
    final response =
        await http.get(Uri.parse("http://127.0.0.1:8080/empresas/listar"));
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

  Future<void> _fetchEmpresaData(int id) async {
    final response =
        await http.get(Uri.parse("http://127.0.0.1:8080/empresas/listar/$id"));
    if (response.statusCode == 200) {
      setState(() {
        var utf8Response = utf8.decode(response.bodyBytes);
        var empresaData = json.decode(utf8Response);

        // Preenche os campos com os dados da empresa
        _nomeFantasiaController.text = empresaData['empresas']['nomeFantasia'];
        _cnpjController.text = empresaData['empresas']['cnpj'];
        _razaoSocialController.text = empresaData['empresas']['razaoSocial'];
        _logradouroController.text = empresaData['empresas']['logradouro'];
        _numeroController.text = empresaData['empresas']['numero'];
        _cepController.text = empresaData['empresas']['cep'];
        _complementoController.text = empresaData['empresas']['complemento'];
        _emailController.text = empresaData['empresas']['email'] != null? empresaData['empresas']['email']:" ";
        _selectedPorte = empresaData['empresas']['porte']['id'].toString();
        _selectedSetor = empresaData['empresas']['setor']['id'].toString();
      });
    } else {
      throw Exception('Falha ao carregar dados da empresa');
    }
  }

  Future<void> _saveEmpresa() async {
    if (_formKey.currentState!.validate()) {
      final apiUrl = "http://127.0.0.1:8080/empresas/editar/${widget.id}";

      Map<String, dynamic> empresaData = {
        "nomeFantasia": _nomeFantasiaController.text,
        "cnpj": _cnpjController.text,
        "razaoSocial": _razaoSocialController.text,
        "logradouro": _logradouroController.text,
        "numero": _numeroController.text,
        "cep": _cepController.text,
        "complemento": _complementoController.text,
        "email": _emailController.text, // Envia o campo de e-mail
        "porte": {
          "id": int.parse(_selectedPorte),
        },
        "setor": {
          "id": int.parse(_selectedSetor),
        },
        "ativa": 1
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(empresaData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Empresa editada com sucesso!')),
        );
        Navigator.of(context).pushReplacementNamed('/empresa');
      } else {
        var responseJson = json.decode(response.body);
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
        title: Text('Editar Empresa'), // Sempre "Editar Empresa"
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
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o e-mail';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor, insira um e-mail válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPorte.isNotEmpty ? _selectedPorte : null,
                decoration: InputDecoration(
                  labelText: 'Porte',
                  border:
                      OutlineInputBorder(), // Mesmo padrão dos TextFormFields
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
                value: _selectedSetor.isNotEmpty ? _selectedSetor : null,
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
                onChanged: (String? value) {
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
                onPressed: _saveEmpresa,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispor dos controladores ao destruir o widget
    _nomeFantasiaController.dispose();
    _cnpjController.dispose();
    _razaoSocialController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _cepController.dispose();
    _complementoController.dispose();
    _emailController.dispose(); // Dispor do controlador de e-mail
    super.dispose();
  }
}
