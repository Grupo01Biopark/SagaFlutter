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
        title: Text('Consumo de API'),
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
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index]['titulo']),
                  subtitle: Text(snapshot.data![index]['descricao']),
                );
              },
            );
          }
        },
      ),
    );
  }
}