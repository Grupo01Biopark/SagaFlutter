import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saga_flutter_app/pages/formulario/formulario.dart';
import 'dart:convert';
import 'package:saga_flutter_app/widgets/main_scaffold.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FormularioRespostasPage extends StatefulWidget {
  final String id;
  final String empresaId;

  FormularioRespostasPage({required this.id, required this.empresaId});

  @override
  _FormularioRespostasPageState createState() =>
      _FormularioRespostasPageState();
}

class _FormularioRespostasPageState extends State<FormularioRespostasPage> {
  late Future<Map<String, dynamic>> formularioData;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "";

  // Mapa para armazenar o estado dos checkboxes e do campo de texto
  Map<int, String> responses =
      {}; // Armazenará as respostas (1, 2, 3 para Conforme, Médio, Não Conforme)
  Map<int, TextEditingController> textControllers =
      {}; // Armazenará os textos para cada pergunta
  int flag = 0;
  // Função para buscar dados da API
  Future<Map<String, dynamic>> fetchData() async {
    final String apiUrl =
        "http://138.186.234.48:8080/formulario/${widget.empresaId}/iniciar/respostas/${widget.id}";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(decodedResponse);
      if (flag == 0) {
        for (var pergunta in jsonResponse['ambiental']['perguntas']) {
          textControllers[pergunta['id']] = TextEditingController();
        }
        for (var pergunta in jsonResponse['social']['perguntas']) {
          textControllers[pergunta['id']] = TextEditingController();
        }
        for (var pergunta in jsonResponse['governanca']['perguntas']) {
          textControllers[pergunta['id']] = TextEditingController();
        }
        flag = 1;
      }
      return jsonResponse;
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }

  void _listen(int perguntaId) async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            textControllers[perguntaId]?.text = _text;
          }),
        );
      }
    } else {
      setState(() => _isListening = false); // reset listening state
      _speech.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    formularioData = fetchData();
    _speech = stt.SpeechToText();
  }

  // Função para construir a lista de cards de perguntas
  Widget buildPerguntasList(List<dynamic> perguntas, String tipo) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: perguntas.length,
      itemBuilder: (context, index) {
        final pergunta = perguntas[index];
        final perguntaId = pergunta['id'];

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
                  onChanged: (bool? value) {
                    setState(() {
                      responses[perguntaId] = value == true ? '1' : '';
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Médio'),
                  value: responses[perguntaId] == '2',
                  onChanged: (bool? value) {
                    setState(() {
                      responses[perguntaId] = value == true ? '2' : '';
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Não Conforme'),
                  value: responses[perguntaId] == '3',
                  onChanged: (bool? value) {
                    setState(() {
                      responses[perguntaId] = value == true ? '3' : '';
                    });
                  },
                ),
                SizedBox(height: 16),

                // Campo de texto (Textarea)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textControllers[perguntaId],
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Digite uma observação aqui...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      onPressed: () => _listen(perguntaId),
                    ),
                  ],
                )
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

  // Função para enviar respostas para a API
  Future<void> enviarRespostas() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifique se os serviços de localização estão habilitados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Serviços de localização estão desabilitados, solicite que o usuário habilite.
      return Future.error('Serviços de localização estão desabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissão negada. Mostre uma mensagem ou trate o erro.
        return Future.error('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissão foi negada permanentemente.
      return Future.error(
          'Permissão de localização negada permanentemente. Não é possível solicitar permissões.');
    }

    // Se a permissão foi concedida, obtenha a localização.
    Position position = await Geolocator.getCurrentPosition();
    print(position);
    // Organizar as respostas por eixo
    final responsesByAxis = {
      'respostasGov': [],
      'respostasAmb': [],
      'respostasSoc': [],
    };

    final responseData = await fetchData();
    final perguntasAmbiental = responseData['ambiental']['perguntas'];
    final perguntasSocial = responseData['social']['perguntas'];
    final perguntasGovernanca = responseData['governanca']['perguntas'];

    for (var pergunta in perguntasAmbiental) {
      print(pergunta);
      print(textControllers[pergunta['id']]);
      responsesByAxis['respostasAmb']?.add({
        'idPergunta': pergunta['id'].toString(),
        'conformidade': responses[pergunta['id']] ?? '',
        'observacoes': textControllers[pergunta['id']]?.text ?? '',
      });
    }

    for (var pergunta in perguntasSocial) {
      responsesByAxis['respostasSoc']?.add({
        'idPergunta': pergunta['id'].toString(),
        'conformidade': responses[pergunta['id']] ?? '',
        'observacoes': textControllers[pergunta['id']]?.text ?? '',
      });
    }

    for (var pergunta in perguntasGovernanca) {
      print(textControllers[pergunta['id']]?.text);
      responsesByAxis['respostasGov']?.add({
        'idPergunta': pergunta['id'].toString(),
        'conformidade': responses[pergunta['id']] ?? '',
        'observacoes': textControllers[pergunta['id']]?.text ?? '',
      });
    }

    // Criar o corpo da requisição
    final requestBody = {
      'respostas': [
        {
          'idFormularioChecklistGov': '1', // Ajuste conforme seu backend
          'respostasGov': responsesByAxis['respostasGov'],
        },
        {
          'idFormularioChecklistAmb': '2', // Ajuste conforme seu backend
          'respostasAmb': responsesByAxis['respostasAmb'],
        },
        {
          'idFormularioChecklistSoc': '3', // Ajuste conforme seu backend
          'respostasSoc': responsesByAxis['respostasSoc'],
        },
      ],
      'coordenadas': position
    };

    // Enviar resposta para o backend
    final apiUrl =
        "http://138.186.234.48:8080/formulario/${widget.id}/iniciar/respostas/${widget.empresaId}/salvar";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(decodedResponse);

      if (jsonResponse['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Respostas salvas com sucesso!',
              style: TextStyle(
                color: Colors.white, // Cor do texto
                fontSize: 16, // Tamanho da fonte
                fontWeight: FontWeight.bold, // Peso da fonte
              ),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScaffold(
                body: FormularioPage(),
                title: 'Formulários',
              ),
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Erro ao salvar respostas: ${jsonResponse['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar respostas.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Fecha o teclado ao tocar fora do campo
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: MainScaffold(
        title: 'Formulários',
        body: FutureBuilder<Map<String, dynamic>>(
          future: formularioData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar dados.'));
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
                floatingActionButton: Container(
                  width: 150, // Ajuste a largura do botão
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      if (validateChecklist()) {
                        enviarRespostas();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Por favor, preencha todos os campos obrigatórios.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Enviar',
                      style: TextStyle(
                        color: Colors.white, // Altere para a cor desejada
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
