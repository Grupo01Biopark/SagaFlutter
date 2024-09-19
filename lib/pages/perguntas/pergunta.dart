import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:saga_flutter_app/pages/perguntas/pergunta_editar.dart';

class ApiListPergunta {
  final String apiUrl = "http://127.0.0.1:8080/perguntas/listar";

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

  @override
  void initState() {
    super.initState();
    _futurePerguntas = apiService.fetchData();
  }

  Future<void> deleteQuestion(String questionId) async {
    final url = 'http://127.0.0.1:8080/perguntas/excluir/$questionId';

    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 201) {
        print('Pergunta excluída com sucesso');
        // Recarregar a lista de perguntas após exclusão
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listagem de Perguntas'),
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
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
                            // SizedBox(height: 8),
                            // Text(
                            //   'Importante: ${item['importante'] == 1 ? 'Sim' : 'Não'}',
                            //   style: TextStyle(fontSize: 14),
                            // ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[100],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    item['eixo']?['titulo'] ?? '',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blueGrey[800]),
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        8.0), // Adiciona um espaço entre os itens
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[100],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    item['setor']?['titulo'] ?? '',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blueGrey[800]),
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        8.0), // Adiciona um espaço entre os itens
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[100],
                                    borderRadius: BorderRadius.circular(8.0),
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
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditPerguntaPage(
                                          perguntaId: item['id'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Confirmar Exclusão'),
                                          content: Text(
                                              'Tem certeza de que deseja excluir esta pergunta?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Fecha o modal
                                              },
                                              child: Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Fecha o modal
                                                deleteQuestion(item['id']
                                                    .toString()); // Substitua com o ID real da pergunta
                                              },
                                              child: Text('Excluir'),
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
                  } else {
                    return SizedBox.shrink();
                  }
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
    home: PerguntaPage(),
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
