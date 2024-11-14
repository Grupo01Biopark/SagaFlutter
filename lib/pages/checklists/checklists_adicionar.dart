import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddChecklistPage extends StatefulWidget {
  @override
  _AddChecklistPage createState() => _AddChecklistPage();
}

class _AddChecklistPage extends State<AddChecklistPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  List<dynamic> eixos = [];
  List<dynamic> setores = [];
  List<dynamic> portes = [];

  List<dynamic> perguntas = [];
  Map<int, bool> perguntasSelecionadas = {};

  String? _selectedEixo;
  String? _selectedSetor;
  String? _selectedPorte;

  @override
  void initState() {
    super.initState();
    _fetchEixosSetoresPortes();
  }

  Future<void> _fetchEixosSetoresPortes() async {
    final response = await http
        .get(Uri.parse("http://138.186.234.48:8080/checklists/listar"));
    if (response.statusCode == 200) {
      setState(() {
        var utf8Response = utf8.decode(response.bodyBytes);
        var decodedData = json.decode(utf8Response);
        eixos = decodedData['eixos'];
        setores = decodedData['setores'];
        portes = decodedData['portes'];
      });
    }
  }

  Future<void> _fetchPerguntas() async {
    final response = await http
        .get(Uri.parse("http://138.186.234.48:8080/perguntas/listar"));
    if (response.statusCode == 200) {
      var utf8Response = utf8.decode(response.bodyBytes);
      var allPerguntas = json.decode(utf8Response)['perguntas'];

      setState(() {
        perguntas = allPerguntas.where((pergunta) {
          return pergunta['eixo']['id'] == int.parse(_selectedEixo!) &&
              pergunta['setor']['id'] == int.parse(_selectedSetor!) &&
              pergunta['porte']['id'] == int.parse(_selectedPorte!);
        }).toList();
      });
    } else {
      throw Exception('Falha ao carregar perguntas');
    }
  }

  void _selecionarTodasPerguntas() {
    setState(() {
      perguntasSelecionadas = {
        for (var pergunta in perguntas) pergunta['id']: true
      };
    });
  }

  Future<void> _saveChecklist() async {
    if (_tituloController.text.isEmpty ||
        _descricaoController.text.isEmpty ||
        _selectedEixo == null ||
        _selectedSetor == null ||
        _selectedPorte == null ||
        perguntasSelecionadas.values.where((v) => v).length < 4) {
      return;
    }

    Map<String, dynamic> checklistData = {
      "titulo": _tituloController.text,
      "descricao": _descricaoController.text,
      "eixo": int.parse(_selectedEixo!),
      "setor": int.parse(_selectedSetor!),
      "porte": int.parse(_selectedPorte!),
      "perguntas": perguntasSelecionadas.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList()
    };

    try {
      final response = await http.post(
        Uri.parse('http://138.186.234.48:8080/checklists/adicionar'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(checklistData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checklist adicionado com sucesso')),
        );
        Navigator.pop(context);
      } else {
        print('Falha ao salvar checklist: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao salvar checklist: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Criar Checklist'),
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
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedEixo,
                decoration: InputDecoration(
                    labelText: 'Eixo', border: OutlineInputBorder()),
                items: eixos.map<DropdownMenuItem<String>>((dynamic eixo) {
                  return DropdownMenuItem<String>(
                    value: eixo['id'].toString(),
                    child: Text(eixo['titulo']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEixo = value;
                    _fetchPerguntas();
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione um eixo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSetor,
                decoration: InputDecoration(
                    labelText: 'Setor', border: OutlineInputBorder()),
                items: setores.map<DropdownMenuItem<String>>((dynamic setor) {
                  return DropdownMenuItem<String>(
                    value: setor['id'].toString(),
                    child: Text(setor['titulo']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSetor = value;
                    _fetchPerguntas();
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione um setor';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPorte,
                decoration: InputDecoration(
                    labelText: 'Porte', border: OutlineInputBorder()),
                items: portes.map<DropdownMenuItem<String>>((dynamic porte) {
                  return DropdownMenuItem<String>(
                    value: porte['id'].toString(),
                    child: Text(porte['titulo']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPorte = value;
                    _fetchPerguntas();
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione um porte';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              if (_selectedEixo != null &&
                  _selectedSetor != null &&
                  _selectedPorte != null) ...[
                Text(
                  'Selecione as Perguntas:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0F6FC6),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: _selecionarTodasPerguntas,
                  child: Text('Selecionar Todas as Perguntas',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
                SizedBox(height: 8),
                perguntas.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: perguntas.length,
                        itemBuilder: (context, index) {
                          var pergunta = perguntas[index];
                          return CheckboxListTile(
                            title: Text(pergunta['descricao']),
                            value:
                                perguntasSelecionadas[pergunta['id']] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                perguntasSelecionadas[pergunta['id']] = value!;
                              });
                            },
                          );
                        },
                      )
                    : Text(
                        'Nenhuma pergunta encontrada para os filtros selecionados.',
                        style: TextStyle(color: Colors.red, fontSize: 16)),
              ],
              SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    perguntasSelecionadas.values.where((v) => v).length >= 4
                        ? _saveChecklist
                        : null,
                child: Text(
                  'Salvar Checklist',
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
