import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saga_flutter_app/pages/formulario/formulario_respostas.dart';
import 'dart:convert';
import 'package:saga_flutter_app/widgets/main_scaffold.dart';

class FormularioIniciarPage extends StatefulWidget {
  final String id;

  FormularioIniciarPage({required this.id});

  @override
  _FormularioIniciarPageState createState() => _FormularioIniciarPageState();
}

class _FormularioIniciarPageState extends State<FormularioIniciarPage> {
  String? _selectedValue;
  List<Map<String, dynamic>> _options = [];

  @override
  void initState() {
    super.initState();
    fetchData().then((data) {
      setState(() {
        _options = data;
      });
    });
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final String apiUrl =
        "http://186.226.48.222:8080/formulario/listar/empresas/${widget.id}";
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(decodedResponse);
      return List<Map<String, dynamic>>.from(jsonResponse['empresas']);
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Iniciar Formulário',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                hint: Text('Selecione uma empresa'),
                value: _selectedValue,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedValue = newValue;
                  });
                },
                items: _options.map<DropdownMenuItem<String>>((empresa) {
                  return DropdownMenuItem<String>(
                    value: empresa['id'].toString(),
                    child: Text('${empresa['nome']} - ${empresa['cnpj']}'),
                  );
                }).toList(),
                style: TextStyle(
                  color: Colors.blueGrey[800],
                  fontSize: 16,
                ),
                dropdownColor: Colors.blueGrey[50],
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF0F6FC6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF0F6FC6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF0F6FC6)),
                  ),
                ),
                icon: Icon(Icons.arrow_drop_down, color: Color(0xFF0F6FC6)),
                isExpanded: true,
                menuMaxHeight: 300,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_selectedValue != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormularioRespostasPage(
                          id: widget.id,
                          empresaId: _selectedValue!,
                        ),
                      ),
                    );
                  } else {
                    // Exibir uma mensagem de erro ou alerta
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Por favor, selecione uma empresa.'),
                      ),
                    );
                  }
                },
                child: Text(
                  'Iniciar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F6FC6),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
