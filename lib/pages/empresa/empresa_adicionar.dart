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
                value: null, // Agora estamos usando _selectedPorte como o valor inicial
                decoration: InputDecoration(
                  labelText: 'Porte',
                  border:
                      OutlineInputBorder(), // Mesmo padrão dos TextFormFields
                ),
                items: portes.map<DropdownMenuItem<String>>((dynamic porte) {
                  return DropdownMenuItem<String>(
                    value: '${porte['id'].toString()}', // O valor que será enviado (ID)
                    child: Text(porte['titulo']), // O texto que será exibido
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedPorte = value
                        .toString(); // Atualiza a variável com o ID selecionado
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
                  border:
                      OutlineInputBorder(), // Mesmo padrão dos TextFormFields
                ),
                items: setores.map<DropdownMenuItem<String>>((dynamic setor) {
                  return DropdownMenuItem<String>(
                    value: '${setor['id'].toString()}', // O valor que será enviado
                    child: Text(setor['titulo']), // O texto que será exibido
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSetor = value.toString(); // Atualiza a seleção
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
                    color: Colors.white, // Define o texto branco
                    fontSize: 20, // Tamanho da fonte opcional
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F6FC6),
                  // Cor do texto quando pressionado
                  padding: EdgeInsets.symmetric(
                      horizontal: 24, vertical: 22), // Padding do botão
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(5), // Bordas arredondadas de 5px
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
