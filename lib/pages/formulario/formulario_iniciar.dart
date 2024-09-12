import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    fetchData().then((data) {
      setState(() {
        _options = data.map<String>((empresa) {
          return '${empresa['nome']} - ${empresa['cnpj']}';
        }).toList();
      });
    });
  }

  Future<List<dynamic>> fetchData() async {
    final String apiUrl = "http://127.0.0.1:8080/formulario/listar/empresas/${widget.id}";
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(decodedResponse);
      return jsonResponse['empresas'];
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
                items: _options.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                style: TextStyle(
                  color: Colors.blueGrey[800],
                  fontSize: 16,
                ),
                dropdownColor: Colors.blueGrey[50],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueGrey),
                  ),
                ),
                icon: Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
                selectedItemBuilder: (BuildContext context) {
                  return _options.map<Widget>((String value) {
                    return Text(
                      value,
                      style: TextStyle(
                        color: Colors.blueGrey[800],
                        fontSize: 16,
                      ),
                    );
                  }).toList();
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Implementar ação de iniciar
                },
                child: Text('Iniciar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}