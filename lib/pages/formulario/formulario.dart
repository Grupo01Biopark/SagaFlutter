import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:saga_flutter_app/pages/formulario/formulario_iniciar.dart';

class ApiFormularioListService {
  final String apiUrl = "http://127.0.0.1:8080/formulario/listar";

  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      return json.decode(decodedResponse);
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }
}

class FormularioPage extends StatefulWidget {
  @override
  _FormularioPageState createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final ApiFormularioListService apiService = ApiFormularioListService();
  Future<List<dynamic>>? _futureFormularios;

  @override
  void initState() {
    super.initState();
    _futureFormularios = apiService.fetchData();
  }

  // Função para excluir o formulário
  Future<void> deleteFormulario(String formularioId) async {
    final url = 'http://127.0.0.1:8080/formulario/excluir/$formularioId';

    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 201) {
        print('Formulário excluído com sucesso');
        // Recarregar a lista de formulários após exclusão
        setState(() {
          _futureFormularios = apiService.fetchData();
        });
      } else {
        print('Falha ao excluir o formulário');
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
        title: Text('Listagem de Formulários'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureFormularios,
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

                  // Valida se o atributo 'ativo' é true
                  if (item['ativo'] == true) {
                    var tags = [
                      item['checklists']['setor'],
                      item['checklists']['porte']
                    ];
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
                            // Título
                            Text(
                              item['titulo'] ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            // Descrição
                            Text(
                              item['descricao'] ?? '',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            // Espaço para tags
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: tags.map<Widget>((tag) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[100],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blueGrey[800]),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 8),
                            // Botões de ação
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.play_arrow),
                                  color: Colors.green,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FormularioIniciarPage(
                                                id: item['id'].toString()),
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
                                              'Tem certeza de que deseja excluir este formulário?'),
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
                                                deleteFormulario(item['id']
                                                    .toString()); // Chama a função de exclusão
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
                    // Se 'ativo' for false, retorna um widget vazio
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
    home: FormularioPage(),
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
