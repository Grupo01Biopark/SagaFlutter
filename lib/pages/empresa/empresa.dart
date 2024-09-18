import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saga_flutter_app/pages/empresa/empresa_editar.dart';
import 'dart:convert';

class ApiListEmpresa {
  final String apiUrl = "http://127.0.0.1:8080/empresas/listar";

  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));
    var utf8Response = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      var decodedData = json.decode(utf8Response);
      if (decodedData is List) {
        return decodedData;
      } else if (decodedData is Map && decodedData['empresas'] != null) {
        return decodedData['empresas'];
      } else {
        return [];
      }
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }
}

class EmpresaPage extends StatefulWidget {
  @override
  _EmpresaPageState createState() => _EmpresaPageState();
}

class _EmpresaPageState extends State<EmpresaPage> {
  final ApiListEmpresa apiService = ApiListEmpresa();
  Future<List<dynamic>>? _futureEmpresas;

  @override
  void initState() {
    super.initState();
    _futureEmpresas = apiService.fetchData();
  }

  Future<void> deleteCompany(String companyId) async {
    final url = 'http://127.0.0.1:8080/empresas/excluir/$companyId';

    try {
      final response = await http.delete(Uri.parse(url));
      print(response.statusCode);
      if (response.statusCode == 201) {
        print('Empresa excluída com sucesso');
        // Recarregar a lista de empresas após exclusão
        setState(() {
          _futureEmpresas = apiService.fetchData();
        });
      } else {
        print('Falha ao excluir a empresa');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listagem de Empresas'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureEmpresas,
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
                  if (item['ativa'] == true) {
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
                              item['nomeFantasia'] ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'CNPJ: ${item['cnpj'] ?? ''}',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Razão Social: ${item['razaoSocial'] ?? ''}',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Endereço: ${item['logradouro'] ?? ''}, ${item['numero'] ?? ''}',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'CEP: ${item['cep'] ?? ''}',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            if (item['complemento'] != null &&
                                item['complemento'] != '')
                              Text(
                                'Complemento: ${item['complemento'] ?? ''}',
                                style: TextStyle(fontSize: 14),
                              ),
                            SizedBox(height: 8),
                            Text(
                              'Data de Cadastro: ${item['dataCadastro'] ?? ''}',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Porte: ${item['porte']?['titulo'] ?? ''}',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Setor: ${item['setor']?['titulo'] ?? ''}',
                              style: TextStyle(fontSize: 14),
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
                                        builder: (context) => EditEmpresaPage(
                                          id: item['id'],
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
                                              'Tem certeza de que deseja excluir esta empresa?'),
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
                                                deleteCompany(item['id']
                                                    .toString()); // Substitua com o ID real da empres
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
    home: EmpresaPage(),
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
