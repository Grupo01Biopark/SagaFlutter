import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditChecklistPage extends StatefulWidget {
  final int checklistId;

  EditChecklistPage({required this.checklistId});

  @override
  _EditChecklistPage createState() => _EditChecklistPage();
}

class _EditChecklistPage extends State<EditChecklistPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchChecklist();
  }

  Future<void> _fetchChecklist() async {
    final response = await http.get(Uri.parse(
        "http://186.226.48.222:8080/checklists/editar/${widget.checklistId}"));
    if (response.statusCode == 200) {
      var utf8Response = utf8.decode(response.bodyBytes);
      var checklistData = json.decode(utf8Response);
      setState(() {
        _tituloController.text = checklistData['titulo'];
        _descricaoController.text = checklistData['descricao'];
      });
    } else {
      throw Exception('Falha ao carregar checklist');
    }
  }

  Future<void> _saveChecklist() async {
    if (_tituloController.text.isEmpty || _descricaoController.text.isEmpty) {
      print('Dados inválidos, todos os campos devem estar preenchidos');
      return;
    }

    Map<String, dynamic> checklistData = {
      "titulo": _tituloController.text,
      "descricao": _descricaoController.text,
    };

    try {
      final response = await http.put(
        Uri.parse(
            'http://186.226.48.222:8080/checklists/editar/${widget.checklistId}'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(checklistData),
      );

      if (response.statusCode == 200) {
        print('Checklist atualizado com sucesso');
        Navigator.pop(context);
      } else {
        print('Falha ao atualizar checklist. Status: ${response.statusCode}');
        print('Erro: ${response.body}');
      }
    } catch (e) {
      print('Erro ao salvar checklist: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Checklist'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                    labelText: 'Título', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o título';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(
                    labelText: 'Descrição', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveChecklist,
                child: Text('Editar Checklist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    )),
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
