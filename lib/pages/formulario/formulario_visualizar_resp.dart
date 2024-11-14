import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:saga_flutter_app/widgets/main_scaffold.dart';

class FormularioRespostasVisuPage extends StatefulWidget {
  final int certId;

  FormularioRespostasVisuPage({required this.certId});

  @override
  _FormularioRespostasVisuPageState createState() =>
      _FormularioRespostasVisuPageState();
}

class _FormularioRespostasVisuPageState
    extends State<FormularioRespostasVisuPage> {
  late Future<Map<String, dynamic>> formularioData;

  // Mapa para armazenar o estado dos checkboxes e do campo de texto
  Map<int, String> responses =
      {}; // Armazenará as respostas (1, 2, 3 para Conforme, Médio, Não Conforme)
  Map<int, TextEditingController> textControllers =
      {}; // Armazenará os textos para cada pergunta

  // Função para buscar dados da API
  Future<Map<String, dynamic>> fetchData() async {
    final String apiUrl =
        "http://138.186.234.48:8080/formulario/respostas/${widget.certId}";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(decodedResponse);

      // Inicializando os controllers de texto e responses para cada pergunta
      initializeControllersAndResponses(jsonResponse['ambiental']['perguntas']);
      initializeControllersAndResponses(jsonResponse['social']['perguntas']);
      initializeControllersAndResponses(
          jsonResponse['governanca']['perguntas']);

      return jsonResponse;
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }

  // Função auxiliar para inicializar controladores de texto e respostas
  void initializeControllersAndResponses(List<dynamic> perguntas) {
    for (var pergunta in perguntas) {
      int perguntaId = pergunta['id'];
      // Inicializa o controlador de texto com a observação vinda da API
      textControllers[perguntaId] = TextEditingController(
        text: pergunta['observacao'] ??
            '', // Preenche com a observação existente, se disponível
      );
      // Inicializa as respostas com as respostas existentes da API
      responses[perguntaId] = pergunta['resposta']?.toString() ?? '';
    }
  }

  @override
  void initState() {
    super.initState();
    formularioData = fetchData();
  }

  // Função para construir a lista de cards de perguntas
  Widget buildPerguntasList(List<dynamic> perguntas, String tipo) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: perguntas.length,
      itemBuilder: (context, index) {
        final pergunta = perguntas[index];
        final perguntaId = pergunta['id'];

        // Desativa os checkboxes se já houver uma resposta selecionada
        bool isLocked = responses[perguntaId] != '';

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
                // Título da Pergunta
                Text(
                  pergunta['pergunta'], // Exibe o texto da pergunta
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                // Descrição da Pergunta
                Text(
                  pergunta['descricao'] ??
                      '', // Exibe o texto da pergunta, se disponível
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),

                // Checkboxes
                CheckboxListTile(
                  title: Text('Conforme'),
                  value: responses[perguntaId] == '1',
                  onChanged: isLocked
                      ? null
                      : (bool? value) {
                          setState(() {
                            responses[perguntaId] = value == true ? '1' : '';
                          });
                        },
                ),
                CheckboxListTile(
                  title: Text('Médio'),
                  value: responses[perguntaId] == '2',
                  onChanged: isLocked
                      ? null
                      : (bool? value) {
                          setState(() {
                            responses[perguntaId] = value == true ? '2' : '';
                          });
                        },
                ),
                CheckboxListTile(
                  title: Text('Não Conforme'),
                  value: responses[perguntaId] == '3',
                  onChanged: isLocked
                      ? null
                      : (bool? value) {
                          setState(() {
                            responses[perguntaId] = value == true ? '3' : '';
                          });
                        },
                ),
                SizedBox(height: 16),

                // Campo de texto (Textarea) - Somente leitura
                TextField(
                  controller: textControllers[perguntaId],
                  readOnly: true, // Bloqueia a edição do campo de observação
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Observações...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Função para validar se todos os checklists foram preenchidos
  bool validateChecklist() {
    bool allFilled = true;

    for (var perguntaId in responses.keys) {
      if (responses[perguntaId] == '') {
        allFilled = false;
        break;
      }
    }

    return allFilled;
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Formulários',
      body: FutureBuilder<Map<String, dynamic>>(
        future: formularioData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar dados. ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Nenhum dado encontrado.'));
          }

          final data = snapshot.data!;
          final nomeFormulario = data['formulario']['nome'];
          final ambiental = data['ambiental']['perguntas'];
          final social = data['social']['perguntas'];
          final governanca = data['governanca']['perguntas'];

          return DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  tabs: [
                    Tab(text: 'Ambiental'),
                    Tab(text: 'Social'),
                    Tab(text: 'Governança'),
                  ],
                  indicatorColor: Color(0xFF0F6FC6),
                  labelColor: Color(0xFF0F6FC6),
                ),
                title: Text(nomeFormulario), // Nome do formulário na AppBar
              ),
              body: TabBarView(
                children: [
                  // Aba Ambiental
                  buildPerguntasList(ambiental, 'ambiental'),
                  // Aba Social
                  buildPerguntasList(social, 'social'),
                  // Aba Governança
                  buildPerguntasList(governanca, 'governanca'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
