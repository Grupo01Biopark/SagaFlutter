import 'package:flutter/material.dart';
import 'package:saga_flutter_app/widgets/main_scaffold.dart';

class FormularioIniciarPage extends StatefulWidget {
  @override
  _FormularioIniciarPageState createState() => _FormularioIniciarPageState();
}

class _FormularioIniciarPageState extends State<FormularioIniciarPage> {
  String? _selectedValue;
  List<String> _options = ['Opção 1', 'Opção 2', 'Opção 3'];

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
              DropdownButton<String>(
                hint: Text('Selecione uma opção'),
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