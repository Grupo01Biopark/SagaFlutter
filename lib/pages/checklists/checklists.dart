import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'checklists_editar.dart';

class ApiListChecklists {
  final String apiUrl = "http://138.186.234.48:8080/checklists/listar";

  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));
    var utf8Response = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      var decodedData = json.decode(utf8Response);
      return decodedData;
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }
}

class ChecklistPage extends StatefulWidget {
  @override
  _ChecklistPageState createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final ApiListChecklists apiService = ApiListChecklists();
  Future<Map<String, dynamic>>? _futureChecklists;

  String? selectedEixo;
  String? selectedSetor;
  String? selectedPorte;
  String? titleFilter; // Filtro de título

  bool showFilters = false;

  List<dynamic> eixos = [];
  List<dynamic> setores = [];
  List<dynamic> portes = [];

  final TextEditingController _tituloController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureChecklists = apiService.fetchData();
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

  Future<void> deleteChecklist(String checklistId) async {
    final url = 'http://138.186.234.48:8080/checklists/inativar/$checklistId';

    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        print('Checklist inativado com sucesso');
        setState(() {
          _futureChecklists = apiService.fetchData();
        });
      } else {
        print('Falha ao inativar o checklist');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  void navigateToEditChecklist(String checklistId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditChecklistPage(checklistId: int.parse(checklistId)),
      ),
    ).then((_) {
      setState(() {
        _futureChecklists = apiService.fetchData();
      });
    });
  }

  List<dynamic> applyFilters(List<dynamic> checklists) {
    return checklists.where((item) {
      final matchEixo =
          selectedEixo == null || item['eixo']['titulo'] == selectedEixo;
      final matchSetor =
          selectedSetor == null || item['setor']['titulo'] == selectedSetor;
      final matchPorte =
          selectedPorte == null || item['porte']['titulo'] == selectedPorte;
      final matchTitle = titleFilter == null ||
          item['titulo']
              .toString()
              .toLowerCase()
              .contains(titleFilter!.toLowerCase());

      return matchEixo && matchSetor && matchPorte && matchTitle;
    }).toList();
  }

  void clearFilters() {
    setState(() {
      selectedEixo = null;
      selectedSetor = null;
      selectedPorte = null;
      titleFilter = null;
      _tituloController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Stack(
          children: [
            Center(
              child: Text(
                'Listagem de Checklists',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    showFilters = !showFilters;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (showFilters)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Divide a largura disponível pelo número de DropdownButtons
                      double dropdownWidth = (constraints.maxWidth - 20) / 3;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: dropdownWidth,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text("Eixo"),
                              value: selectedEixo,
                              items: eixos.map<DropdownMenuItem<String>>(
                                  (dynamic eixo) {
                                return DropdownMenuItem<String>(
                                  value: eixo['titulo'],
                                  child: Text(eixo['titulo']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedEixo = value);
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: dropdownWidth,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text("Setor"),
                              value: selectedSetor,
                              items: setores.map<DropdownMenuItem<String>>(
                                  (dynamic setor) {
                                return DropdownMenuItem<String>(
                                  value: setor['titulo'],
                                  child: Text(setor['titulo']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedSetor = value);
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: dropdownWidth,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text("Porte"),
                              value: selectedPorte,
                              items: portes.map<DropdownMenuItem<String>>(
                                  (dynamic porte) {
                                return DropdownMenuItem<String>(
                                  value: porte['titulo'],
                                  child: Text(porte['titulo']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedPorte = value);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: _tituloController,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        titleFilter = value.isNotEmpty ? value : null;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: clearFilters,
                    child: Text(
                      "Limpar Filtros",
                      style: TextStyle(
                        color: Colors.white, // Define o texto branco
                        fontSize: 20, // Tamanho da fonte opcional
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0F6FC6),
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _futureChecklists,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    snapshot.data!['checklists'].isEmpty) {
                  return Center(child: Text('Nenhum dado encontrado'));
                } else {
                  List<dynamic> checklists =
                      applyFilters(snapshot.data!['checklists']);
                  return ListView.builder(
                    itemCount: checklists.length,
                    itemBuilder: (context, index) {
                      var item = checklists[index];
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['titulo'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Descrição: ${item['descricao'] ?? ''}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildTag(item['eixo']?['titulo']),
                                  SizedBox(width: 8),
                                  _buildTag(item['setor']?['titulo']),
                                  SizedBox(width: 8),
                                  _buildTag(item['porte']?['titulo']),
                                ],
                              ),
                              SizedBox(height: 16),
                              item['formularioChecklists'] != null &&
                                      item['formularioChecklists'].isNotEmpty
                                  ? Text(
                                      'Quantidade de Formulários: ${item['formularioChecklists'].length}',
                                      style: TextStyle(fontSize: 14),
                                    )
                                  : SizedBox.shrink(),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      navigateToEditChecklist(
                                          item['id'].toString());
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirmar Inativação'),
                                            content: Text(
                                                'Tem certeza de que deseja inativar este checklist?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  deleteChecklist(
                                                      item['id'].toString());
                                                },
                                                child: Text('Inativar'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String? text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Text(
        text ?? '',
        style: TextStyle(color: Colors.blueGrey[800]),
      ),
    );
  }
}
