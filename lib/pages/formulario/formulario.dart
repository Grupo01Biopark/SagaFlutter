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
            return Column(

              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 30,
                    headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[200]!),
                    headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
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
                        ],
                      );
                    }).toList(),
                    border: TableBorder.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                ),
              ],
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
  ));
}