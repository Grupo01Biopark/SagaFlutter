import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPerguntaPage extends StatefulWidget {
  @override
  _AddPerguntaPageState createState() => _AddPerguntaPageState();
}

class _AddPerguntaPageState extends State<AddPerguntaPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  bool _importante = false; // Campo booleano para a importância da pergunta

  String _selectedEixo = ""; // Variável para armazenar a seleção de Eixo
  String _selectedPorte = ""; // Variável para armazenar a seleção de Porte
  String _selectedSetor = ""; // Variável para armazenar a seleção de Setor

  List<dynamic> eixos = [];
  List<dynamic> portes = [];
  List<dynamic> setores = [];

  @override
  void initState() {
    super.initState();
    _fetchEixosPortesSetores();
  }

  Future<void> _fetchEixosPortesSetores() async {
    final response = await http
        .get(Uri.parse("http://138.186.234.48:8080/perguntas/listar"));
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

  Future<void> _addPergunta() async {
    if (_formKey.currentState!.validate()) {
      final apiUrl = "http://138.186.234.48:8080/perguntas/adicionar";

      Map<String, dynamic> perguntaData = {
        "titulo": _tituloController.text,
        "descricao": _descricaoController.text,
        "importante": _importante ? 1 : 0,
        "ativa": 1,
        "eixo": {
          "titulo": _selectedEixo,
        },
        "porte": {
          "titulo": _selectedPorte,
        },
        "setor": {
          "titulo": _selectedSetor,
        }
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(perguntaData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pergunta adicionada com sucesso!')),
        );
        Navigator.of(context).pushReplacementNamed('/pergunta');
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
        automaticallyImplyLeading: false,
        title: Text('Adicionar Pergunta'),
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
                value:
                    null, // Agora estamos usando _selectedEixo como o valor inicial
                decoration: InputDecoration(
                  labelText: 'Eixo',
                  border: OutlineInputBorder(),
                ),
                items: eixos.map<DropdownMenuItem<String>>((dynamic eixo) {
                  return DropdownMenuItem<String>(
                    value: eixo['titulo'], // O valor que será enviado (ID)
                    child: Text(eixo['titulo']), // O texto que será exibido
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedEixo = value
                        .toString(); // Atualiza a variável com o ID selecionado
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
                value: null,
                decoration: InputDecoration(
                  labelText: 'Porte',
                  border: OutlineInputBorder(),
                ),
                items: portes.map<DropdownMenuItem<String>>((dynamic porte) {
                  return DropdownMenuItem<String>(
                    value: porte['titulo'],
                    child: Text(porte['titulo']), // O texto que será exibido
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedPorte = value.toString(); // Atualiza a seleção
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
                value: null,
                decoration: InputDecoration(
                  labelText: 'Setor',
                  border: OutlineInputBorder(),
                ),
                items: setores.map<DropdownMenuItem<String>>((dynamic setor) {
                  return DropdownMenuItem<String>(
                    value: setor['titulo'], // O valor que será enviado
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
                    return 'Por favor, selecione o setor da pergunta';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addPergunta,
                child: Text(
                  'Adicionar Pergunta',
                  style: TextStyle(
                    color: Colors.white, // Define o texto branco
                    fontSize: 20, // Tamanho da fonte opcional
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F6FC6),
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
    home: AddPerguntaPage(),
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
