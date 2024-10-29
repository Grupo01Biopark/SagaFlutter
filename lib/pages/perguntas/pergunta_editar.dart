import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:saga_flutter_app/pages/perguntas/pergunta.dart';

class EditPerguntaPage extends StatefulWidget {
  final int perguntaId; // Recebe o ID da pergunta para ser editada

  EditPerguntaPage({required this.perguntaId});

  @override
  _EditPerguntaPageState createState() => _EditPerguntaPageState();
}

class _EditPerguntaPageState extends State<EditPerguntaPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  bool _importante = false;

  String _selectedEixo = "";
  String _selectedPorte = "";
  String _selectedSetor = "";

  List<dynamic> eixos = [];
  List<dynamic> portes = [];
  List<dynamic> setores = [];

  @override
  void initState() {
    super.initState();
    _fetchPerguntaData(); // Carrega os dados da pergunta para edição
    _fetchEixosPortesSetores();
  }

  Future<void> _fetchPerguntaData() async {
    final response = await http.get(Uri.parse(
        "http://186.226.48.222:8080/perguntas/listar/${widget.perguntaId}"));

    if (response.statusCode == 200) {
      var utf8Response = utf8.decode(response.bodyBytes);
      var perguntaData = json.decode(utf8Response);

      setState(() {
        _tituloController.text = perguntaData['pergunta']['titulo'];
        _descricaoController.text = perguntaData['pergunta']['descricao'];
        _importante = perguntaData['pergunta']['importante'] == 1;
        _selectedEixo = perguntaData['pergunta']['eixo']['titulo'];
        _selectedPorte = perguntaData['pergunta']['porte']['titulo'];
        _selectedSetor = perguntaData['pergunta']['setor']['titulo'];
      });
    } else {
      throw Exception('Falha ao carregar dados da pergunta');
    }
  }

  Future<void> _fetchEixosPortesSetores() async {
    final response = await http
        .get(Uri.parse("http://186.226.48.222:8080/perguntas/listar"));
    if (response.statusCode == 200) {
      setState(() {
        var utf8Response = utf8.decode(response.bodyBytes);
        var decodedData = json.decode(utf8Response);
        eixos = decodedData['eixos'];
        portes = decodedData['portes'];
        setores = decodedData['setores'];
      });
    } else {
      throw Exception('Falha ao carregar eixos, portes e setores');
    }
  }

  Future<void> _editPergunta() async {
    if (_formKey.currentState!.validate()) {
      final apiUrl =
          "http://186.226.48.222:8080/perguntas/editar/${widget.perguntaId}";

      Map<String, dynamic> perguntaData = {
        "titulo": _tituloController.text,
        "descricao": _descricaoController.text,
        "importante": _importante ? 1 : 0,
        "porte": {
          "id": 0,
          "titulo": _selectedPorte,
        },
        "setor": {
          "id": 0,
          "titulo": _selectedSetor,
        },
        "eixo": {
          "id": 0,
          "titulo": _selectedEixo,
        },
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(perguntaData),
      );

      if (response.statusCode == 201 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pergunta editada com sucesso!')),
        );
        Navigator.of(context).pushReplacementNamed('/pergunta');
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
        title: Text('Editar Pergunta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                    labelText: 'Título', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o título';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(
                    labelText: 'Descrição', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição';
                  }
                  return null;
                },
              ),
              // SizedBox(height: 16),
              // SwitchListTile(
              //   title: Text('Importante'),
              //   value: _importante,
              //   onChanged: (bool value) {
              //     setState(() {
              //       _importante = value;
              //     });
              //   },
              // ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedEixo.isNotEmpty ? _selectedEixo : null,
                decoration: InputDecoration(
                  labelText: 'Eixo',
                  border: OutlineInputBorder(),
                ),
                items: eixos.map<DropdownMenuItem<String>>((dynamic eixo) {
                  return DropdownMenuItem<String>(
                    value: eixo['titulo'],
                    child: Text(eixo['titulo']),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedEixo = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o eixo da pergunta';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPorte.isNotEmpty ? _selectedPorte : null,
                decoration: InputDecoration(
                  labelText: 'Porte',
                  border: OutlineInputBorder(),
                ),
                items: portes.map<DropdownMenuItem<String>>((dynamic porte) {
                  return DropdownMenuItem<String>(
                    value: porte['titulo'],
                    child: Text(porte['titulo']),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedPorte = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o porte da pergunta';
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
                    value: setor['titulo'],
                    child: Text(setor['titulo']),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedSetor = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o setor da pergunta';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _editPergunta,
                child: Text(
                  'Editar Pergunta',
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
    home: EditPerguntaPage(perguntaId: 1), // Passe o ID da pergunta para edição
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
