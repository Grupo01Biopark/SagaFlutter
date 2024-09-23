import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'checklists_editar.dart';

class ApiListChecklists {
  final String apiUrl = "http://127.0.0.1:8080/checklists/listar";

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

  @override
  void initState() {
    super.initState();
    _futureChecklists = apiService.fetchData();
  }

  Future<void> deleteChecklist(String checklistId) async {
    final url = 'http://127.0.0.1:8080/checklists/inativar/$checklistId';

    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        print('Checklist inativado com sucesso');
        // Recarregar a lista de checklists após exclusão
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
        builder: (context) => EditChecklistPage(checklistId: int.parse(checklistId)),
      ),
    ).then((_) {
      setState(() {
        _futureChecklists = apiService.fetchData();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listagem de Checklists'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureChecklists,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!['checklists'].isEmpty) {
            return Center(child: Text('Nenhum dado encontrado'));
          } else {
            List<dynamic> checklists = snapshot.data!['checklists'];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
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
                          Text(
                            'Eixo: ${item['eixo']?['titulo'] ?? ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Setor: ${item['setor']?['titulo'] ?? ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Porte: ${item['porte']?['titulo'] ?? ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 16),
                          item['formularioChecklists'] != null && item['formularioChecklists'].isNotEmpty
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
                                  navigateToEditChecklist(item['id'].toString());
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
                                        content: Text('Tem certeza de que deseja inativar este checklist?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Fecha o modal
                                            },
                                            child: Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Fecha o modal
                                              deleteChecklist(item['id'].toString());
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
              ),
            );
          }
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ChecklistPage(),
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
