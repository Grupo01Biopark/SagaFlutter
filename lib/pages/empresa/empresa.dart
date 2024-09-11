import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:saga_flutter_app/pages/formulario/formulario_iniciar.dart';

class ApiListEmpresa {
  final String apiUrl = "http://127.0.0.1:8080/empresas/listar";

  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Check if the API returns a list or a map
      var decodedData = json.decode(response.body);

      if (decodedData is List) {
        // If the data is a list, return it directly
        return decodedData;
      } else if (decodedData is Map && decodedData['empresas'] != null) {
        // If the data is a map and contains a list of empresas
        return decodedData['empresas'];
      } else {
        // If the data is neither, return an empty list
        return [];
      }
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }
}

class EmpresaPage extends StatelessWidget {
  final ApiListEmpresa apiService = ApiListEmpresa();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listagem de Empresas'),
        iconTheme: IconThemeData(color: Colors.white),
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var item = snapshot.data![index];
                  if (item['ativa'] == false) {
                    return null;
                  }
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
                          // Nome Fantasia
                          Text(
                            item['nomeFantasia'] ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          // CNPJ
                          Text(
                            'CNPJ: ${item['cnpj'] ?? ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          // Razão Social
                          Text(
                            'Razão Social: ${item['razaoSocial'] ?? ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          // Endereço
                          Text(
                            'Endereço: ${item['logradouro'] ?? ''}, ${item['numero'] ?? ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          // CEP
                          Text(
                            'CEP: ${item['cep'] ?? ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          // Complemento (if exists)
                          if (item['complemento'] != null &&
                              item['complemento'] != '')
                            Text(
                              'Complemento: ${item['complemento'] ?? ''}',
                              style: TextStyle(fontSize: 14),
                            ),
                          SizedBox(height: 8),
                          // Data de Cadastro
                          Text(
                            'Data de Cadastro: ${item['dataCadastro'] ?? ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          // Porte
                          Text(
                            'Porte: ${item['porte']?['titulo'] ?? ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          // Setor
                          Text(
                            'Setor: ${item['setor']?['titulo'] ?? ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 16),
                          // Botões de ação
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
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
    home: EmpresaPage(),
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
