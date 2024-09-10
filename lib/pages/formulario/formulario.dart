import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiFormularioListService {
  final String apiUrl = "http://127.0.0.1:8080/formulario/listar";

  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }
}

class FormularioPage extends StatelessWidget {
  final ApiFormularioListService apiService = ApiFormularioListService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listagem de Formulários'),
        iconTheme: IconThemeData(color: Colors.white), // Define a cor do ícone como branca
      ),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum dado encontrado'));
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),  // Adiciona espaçamento ao redor da tabela
                  child: Center(  // Centraliza horizontalmente
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // Sombra para dar um aspecto de card
                          ),
                        ],
                      ),
                      child: DataTable(
                        columnSpacing: 30,
                        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey[800]!),
                        headingTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        dataRowColor: MaterialStateColor.resolveWith((states) {
                          return states.contains(MaterialState.selected)
                              ? Colors.grey[300]!
                              : Colors.white;
                        }),
                        dataTextStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        columns: [
                          DataColumn(
                            label: Text('Título'),
                          ),
                          DataColumn(
                            label: Text('Descrição'),
                          ),
                          DataColumn(
                            label: Text('Ações'),
                          ),
                        ],
                        rows: snapshot.data!.asMap().entries.map<DataRow>((entry) {
                          int index = entry.key;
                          var item = entry.value;
                          return DataRow(
                            color: MaterialStateColor.resolveWith((states) {
                              return index % 2 == 0 ? Colors.grey[100]! : Colors.white;
                            }),
                            cells: [
                              DataCell(Text(item['titulo'] ?? '')),
                              DataCell(Text(item['descricao'] ?? '')),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      // Implementar ação de edição
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      // Implementar ação de exclusão
                                    },
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                        border: TableBorder(
                          horizontalInside: BorderSide(color: Colors.grey, width: 0.5),
                          verticalInside: BorderSide.none, // Remover bordas verticais
                        ),
                      ),
                    ),
                  ),
                ),
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