import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiFormularioListService {
  final String apiUrl = "http://127.0.0.1:8080/formulario";
  final String apiAdicionarUrl = "http://127.0.0.1:8080/formulario/adicionar";

  // Novo endpoint para perguntas
  final String perguntasUrl = "http://127.0.0.1:8080/checklists";

  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      return json.decode(decodedResponse);
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }

  Future<void> adicionarFormulario(Map<String, dynamic> formularioData) async {
    print("teste");
    final response = await http.post(
      Uri.parse(apiAdicionarUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(formularioData),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao adicionar formulário');
    }
  }

  // Função para buscar as perguntas do checklist
  Future<List<dynamic>> fetchPerguntas(String checklistId) async {
    final response =
        await http.get(Uri.parse('$perguntasUrl/$checklistId/perguntas'));
    if (response.statusCode == 200) {
      var utf8Response = utf8.decode(response.bodyBytes);
      var decodedData = json.decode(utf8Response);

      return decodedData;
    } else {
      throw Exception('Erro ao buscar perguntas');
    }
  }
}

class FormularioCadastroPage extends StatefulWidget {
  @override
  _FormularioCadastroPageState createState() => _FormularioCadastroPageState();
}

class _FormularioCadastroPageState extends State<FormularioCadastroPage> {
  final ApiFormularioListService apiService = ApiFormularioListService();

  String? selectedGovernanca;
  String? selectedSocial;
  String? selectedAmbiental;
  String? titulo;
  String? descricao;

  List<dynamic> governancaChecklists = [];
  List<dynamic> socialChecklists = [];
  List<dynamic> ambientalChecklists = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      Map<String, dynamic> data = await apiService.fetchData();
      setState(() {
        governancaChecklists = data['governancaChecklists'];
        socialChecklists = data['socialChecklists'];
        ambientalChecklists = data['ambientalChecklists'];
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
  }

  Future<void> _cadastrarFormulario() async {
    if (titulo != null &&
        descricao != null &&
        selectedGovernanca != null &&
        selectedSocial != null &&
        selectedAmbiental != null) {
      Map<String, dynamic> formularioData = {
        "titulo": titulo,
        "descricao": descricao,
        "governancaChecklist": governancaChecklists
            .firstWhere((item) => item['titulo'] == selectedGovernanca)['id'],
        "socialChecklist": socialChecklists
            .firstWhere((item) => item['titulo'] == selectedSocial)['id'],
        "ambientalChecklist": ambientalChecklists
            .firstWhere((item) => item['titulo'] == selectedAmbiental)['id'],
      };

      try {
        await apiService.adicionarFormulario(formularioData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Formulário cadastrado com sucesso',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao cadastrar formulário')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Preencha todos os campos')));
    }
  }

  // Função para exibir as perguntas em um modal
  Future<void> _showPerguntasModal(String checklistId) async {
    try {
      List<dynamic> perguntas = await apiService.fetchPerguntas(checklistId);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Perguntas do Checklist'),
            content: perguntas.isNotEmpty
                ? SingleChildScrollView(
                    child: ListBody(
                      children: perguntas.map((pergunta) {
                        return ListTile(
                          title: Text(pergunta[0]), // Título da pergunta
                          subtitle: Text(
                              'Descrição:${pergunta[1]} Categoria: ${pergunta[2]}, Setor: ${pergunta[3]}, Porte: ${pergunta[4]}'),
                        );
                      }).toList(),
                    ),
                  )
                : Text('Nenhuma pergunta encontrada.'),
            actions: <Widget>[
              TextButton(
                child: Text('Fechar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Erro ao buscar perguntas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Formulário'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Título',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  titulo = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Digite o título',
              ),
            ),
            SizedBox(height: 16),
            Text('Descrição',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  descricao = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Digite a descrição',
              ),
            ),
            SizedBox(height: 16),
            Text('Governança',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildDropdownWithButton(
              title: 'Governança Checklist',
              items: governancaChecklists,
              selectedValue: selectedGovernanca,
              onChanged: (value) {
                setState(() {
                  selectedGovernanca = value;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Social',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildDropdownWithButton(
              title: 'Social Checklist',
              items: socialChecklists,
              selectedValue: selectedSocial,
              onChanged: (value) {
                setState(() {
                  selectedSocial = value;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Ambiental',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildDropdownWithButton(
              title: 'Ambiental Checklist',
              items: ambientalChecklists,
              selectedValue: selectedAmbiental,
              onChanged: (value) {
                setState(() {
                  selectedAmbiental = value;
                });
              },
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cadastrarFormulario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F6FC6),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Cadastrar',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Função para construir Dropdown com botão "Visualizar"
  Widget _buildDropdownWithButton({
    required String title,
    required List<dynamic> items,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            items: items.map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem<String>(
                value: item['id'].toString(),
                child: Text(item['titulo']),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Selecione um checklist',
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: selectedValue != null
              ? () {
                  // Exibir modal com as perguntas do checklist selecionado
                  _showPerguntasModal(selectedValue!);
                }
              : null, // Desabilita o botão se nenhum checklist estiver selecionado
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0F6FC6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Visualizar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FormularioCadastroPage(),
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
