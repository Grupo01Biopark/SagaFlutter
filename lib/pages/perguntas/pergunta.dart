import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:saga_flutter_app/pages/perguntas/pergunta_editar.dart';

class ApiListPergunta {
  final String apiUrl = "http://138.186.234.48:8080/perguntas/listar";

  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));

    var utf8Response = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      var decodedData = json.decode(utf8Response);
      if (decodedData is List) {
        return decodedData;
      } else if (decodedData is Map && decodedData['perguntas'] != null) {
        return decodedData['perguntas'];
      } else {
        return [];
      }
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }
}

class PerguntaPage extends StatefulWidget {
  @override
  _PerguntaPageState createState() => _PerguntaPageState();
}

class _PerguntaPageState extends State<PerguntaPage> {
  final ApiListPergunta apiService = ApiListPergunta();
  Future<List<dynamic>>? _futurePerguntas;
  bool _isFilterVisible = false;
  String? _selectedEixo;
  String? _selectedSetor;
  String? _selectedPorte;
  String? _searchTerm;

  List<dynamic> eixos = [];
  List<dynamic> portes = [];
  List<dynamic> setores = [];

  final TextEditingController _tituloController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futurePerguntas = apiService.fetchData();
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

  Future<void> deleteQuestion(String questionId) async {
    final url = 'http://138.186.234.48:8080/perguntas/excluir/$questionId';

    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 201) {
        print('Pergunta excluída com sucesso');
        setState(() {
          _futurePerguntas = apiService.fetchData();
        });
      } else {
        print('Falha ao excluir a pergunta');
        print(response.body);
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedEixo = null;
      _selectedSetor = null;
      _selectedPorte = null;
      _searchTerm = null;

      _tituloController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.white),
        title: Stack(
          children: [
            Center(
              child: Text(
                'Listagem de Perguntas',
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
                    _isFilterVisible = !_isFilterVisible;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isFilterVisible)
            Container(
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Divide a largura disponível pelo número de DropdownButtons
                        double dropdownWidth = (constraints.maxWidth - 16) / 3;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: dropdownWidth,
                              child: DropdownButton<String>(
                                isExpanded:
                                    true, // Permite que o texto ocupe toda a largura
                                hint: Text('Eixo'),
                                value: _selectedEixo,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedEixo = newValue;
                                  });
                                },
                                items: eixos.map<DropdownMenuItem<String>>(
                                    (dynamic eixo) {
                                  return DropdownMenuItem<String>(
                                    value: eixo['titulo'],
                                    child: Text(eixo['titulo']),
                                  );
                                }).toList(),
                              ),
                            ),
                            Container(
                              width: dropdownWidth,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text('Setor'),
                                value: _selectedSetor,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedSetor = newValue;
                                  });
                                },
                                items: setores.map<DropdownMenuItem<String>>(
                                    (dynamic setor) {
                                  return DropdownMenuItem<String>(
                                    value: setor['titulo'],
                                    child: Text(setor['titulo']),
                                  );
                                }).toList(),
                              ),
                            ),
                            Container(
                              width: dropdownWidth,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text('Porte'),
                                value: _selectedPorte,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedPorte = newValue;
                                  });
                                },
                                items: portes.map<DropdownMenuItem<String>>(
                                    (dynamic porte) {
                                  return DropdownMenuItem<String>(
                                    value: porte['titulo'],
                                    child: Text(porte['titulo']),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        labelText: 'Buscar por título',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchTerm = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _clearFilters,
                      child: Text(
                        'Limpar Filtros',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
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
            ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _futurePerguntas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Nenhum dado encontrado'));
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var item = snapshot.data![index];
                        if (item["ativa"] == true) {
                          // Aplica o filtro
                          bool matchesSearch = _searchTerm == null ||
                                  item['titulo']
                                      ?.toLowerCase()
                                      ?.contains(_searchTerm!.toLowerCase()) ??
                              false;
                          bool matchesEixo = _selectedEixo == null ||
                              item['eixo']?['titulo'] == _selectedEixo;
                          bool matchesSetor = _selectedSetor == null ||
                              item['setor']?['titulo'] == _selectedSetor;
                          bool matchesPorte = _selectedPorte == null ||
                              item['porte']?['titulo'] == _selectedPorte;

                          if (matchesSearch &&
                              matchesEixo &&
                              matchesSetor &&
                              matchesPorte) {
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
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4.0),
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey[100],
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Text(
                                            item['eixo']?['titulo'] ?? '',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blueGrey[800]),
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4.0),
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey[100],
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Text(
                                            item['setor']?['titulo'] ?? '',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blueGrey[800]),
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4.0),
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey[100],
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Text(
                                            item['porte']?['titulo'] ?? '',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blueGrey[800]),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditPerguntaPage(
                                                        perguntaId: item['id']),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () async {
                                            bool confirmDelete =
                                                await showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Confirmação'),
                                                content: Text(
                                                    'Tem certeza que deseja excluir a pergunta?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    },
                                                    child: Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    },
                                                    child: Text('Excluir'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirmDelete == true) {
                                              deleteQuestion(
                                                  item['id'].toString());
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
