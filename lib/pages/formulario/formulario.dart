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
  List<dynamic> formularios = [];
  bool _mostrarFiltros = false;

  String? filtroNome;
  String? filtroSetor;
  String? filtroPorte;

  final TextEditingController _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarFormularios();
  }

  Future<void> _carregarFormularios() async {
    _futureFormularios = apiService.fetchData();
    List<dynamic> data = await _futureFormularios!;
    
    setState(() {
      formularios = data;
    });
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

  List<dynamic> _filtrarFormularios() {
    return formularios.where((formulario) {
      final nomeMatch = filtroNome == null ||
              formulario['titulo']
                  ?.toLowerCase()
                  .contains(filtroNome!.toLowerCase()) ??
          false;
      final setorMatch =
          filtroSetor == null || formulario['checklists']['setor'] == filtroSetor;
      final porteMatch =
          filtroPorte == null || formulario['checklists']['porte'] == filtroPorte;
      return nomeMatch && setorMatch && porteMatch && formulario['ativo'] == true;
    }).toList();
  }

  void _limparFiltros() {
    setState(() {
      filtroNome = null;
      filtroSetor = null;
      filtroPorte = null;
      _nomeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Stack(
          children: [
            Center(
              child: Text(
                'Listagem de Formularios',
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
                            items: formularios
                                .map((formulario) => formulario['checklists']['setor'])
                                .where((titulo) => titulo != null)
                                .toSet()
                                .map((titulo) {
                              return DropdownMenuItem<String>(
                                value: titulo,
                                child: Text(titulo),
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
                            items: formularios
                                .map((formulario) => formulario['checklists']['porte'])
                                .where((titulo) => titulo != null)
                                .toSet()
                                .map((titulo) {
                              return DropdownMenuItem<String>(
                                value: titulo,
                                child: Text(titulo),
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
                      ElevatedButton(
                        onPressed: _limparFiltros,
                        child: Text(
                          'Limpar Filtros',
                          style: TextStyle(
                            color: Colors.white,
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
              future: _futureFormularios,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Nenhum dado encontrado'));
                } else {
                  formularios = snapshot.data!; // Atribui os dados à lista
                  final filteredFormularios = _filtrarFormularios();

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      itemCount: filteredFormularios.length,
                      itemBuilder: (context, index) {
                        var item = filteredFormularios[index];

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
                                Text(
                                  item['titulo'] ?? '',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  item['descricao'] ?? '',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: tags.map<Widget>((tag) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey[100],
                                        borderRadius:
                                            BorderRadius.circular(8.0),
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
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    deleteFormulario(
                                                        item['id'].toString());
                                                    Navigator.of(context).pop();
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


void main() {
  runApp(MaterialApp(
    home: FormularioPage(),
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
