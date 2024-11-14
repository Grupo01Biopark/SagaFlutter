import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:saga_flutter_app/pages/empresa/empresa_editar.dart';

class ApiListEmpresa {
  final String apiUrl = "http://138.186.234.48:8080/empresas/listar";

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
  List<dynamic> empresas = [];
  bool _mostrarFiltros = false;

  String? filtroNome;
  String? filtroSetor;
  String? filtroPorte;
  String? filtroCnpj;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cnpjController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarEmpresas();
  }

  Future<void> _carregarEmpresas() async {
    _futureEmpresas = apiService.fetchData();
    List<dynamic> data = await _futureEmpresas!;
    setState(() {
      empresas = data;
    });
  }

  List<dynamic> _filtrarEmpresas() {
    return empresas.where((empresa) {
      final nomeMatch = filtroNome == null ||
              empresa['nomeFantasia']
                  ?.toLowerCase()
                  .contains(filtroNome!.toLowerCase()) ??
          false;
      final setorMatch =
          filtroSetor == null || empresa['setor']?['titulo'] == filtroSetor;
      final porteMatch =
          filtroPorte == null || empresa['porte']?['titulo'] == filtroPorte;
      final cnpjMatch = filtroCnpj == null ||
              empresa['cnpj']
                  ?.toLowerCase()
                  .contains(filtroCnpj!.toLowerCase()) ??
          false;
      return nomeMatch &&
          setorMatch &&
          porteMatch &&
          cnpjMatch &&
          empresa['ativa'] == true;
    }).toList();
  }

  Future<void> deleteCompany(String companyId) async {
    final url = 'http://138.186.234.48:8080/empresas/excluir/$companyId';

    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 201) {
        print('Empresa excluída com sucesso');
        _carregarEmpresas();
      } else {
        print('Falha ao excluir a empresa');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  // Função para limpar os filtros
  void _limparFiltros() {
    setState(() {
      filtroNome = null;
      filtroSetor = null;
      filtroPorte = null;
      filtroCnpj = null;

      // Limpa o texto dos controladores
      _nomeController.clear();
      _cnpjController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: [
            Center(
              child: Text(
                'Listagem de Empresas',
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
                    _mostrarFiltros = !_mostrarFiltros;
                  });
                },
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_mostrarFiltros)
                  Column(
                    children: [
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          DropdownButton<String>(
                            hint: Text('Filtrar por Setor'),
                            value: filtroSetor,
                            items: empresas
                                .map((empresa) => empresa['setor']?['titulo'])
                                .where((titulo) => titulo != null)
                                .toSet()
                                .map((titulo) {
                              return DropdownMenuItem<String>(
                                value: titulo,
                                child: Text(titulo!),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                filtroSetor = value;
                              });
                            },
                          ),
                          SizedBox(height: 8),
                          DropdownButton<String>(
                            hint: Text('Filtrar por Porte'),
                            value: filtroPorte,
                            items: empresas
                                .map((empresa) => empresa['porte']?['titulo'])
                                .where((titulo) => titulo != null)
                                .toSet()
                                .map((titulo) {
                              return DropdownMenuItem<String>(
                                value: titulo,
                                child: Text(titulo!),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                filtroPorte = value;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          labelText: 'Buscar por Nome',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            filtroNome = value;
                          });
                        },
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _cnpjController,
                        decoration: InputDecoration(
                          labelText: 'Buscar por CNPJ',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            filtroCnpj = value;
                          });
                        },
                      ),
                      SizedBox(height: 8), // Espaçamento entre input e botão
                      ElevatedButton(
                        onPressed: _limparFiltros,
                        child: Text(
                          'Limpar Filtros',
                          style: TextStyle(
                            color: Colors.white, // Define o texto branco
                            fontSize: 20, // Tamanho da fonte opcional
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0F6FC6),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _futureEmpresas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Nenhum dado encontrado'));
                } else {
                  List<dynamic> empresasFiltradas = _filtrarEmpresas();
                  return ListView.builder(
                    itemCount: empresasFiltradas.length,
                    itemBuilder: (context, index) {
                      var item = empresasFiltradas[index];
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
                                'E-mail: ${item['email'] ?? ''}',
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
                                      borderRadius: BorderRadius.circular(8.0),
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
                                          color: Colors.blueGrey[800],
                                        ),
                                      )),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditEmpresaPage(
                                            id: item[
                                                'id'], // Adicione o ID da empresa
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
                                        builder: (context) => AlertDialog(
                                          title: Text('Excluir Empresa'),
                                          content: Text(
                                              'Tem certeza que deseja excluir ${item['nomeFantasia']}?'),
                                          actions: [
                                            TextButton(
                                              child: Text('Cancelar'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Excluir'),
                                              onPressed: () {
                                                deleteCompany(item['id']);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
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
}
