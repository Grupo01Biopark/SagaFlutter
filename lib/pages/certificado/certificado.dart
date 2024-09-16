import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiCertificadoListService {
  final String apiUrl = "http://127.0.0.1:8080/certificado/listar";

  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['certificados']; // Ajustando para a chave correta
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }
}

class CertificadoPage extends StatelessWidget {
  final ApiCertificadoListService apiService = ApiCertificadoListService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listagem de Certificados'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum dado encontrado'));
          } else {
            // Define as colunas da tabela
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Permite rolar horizontalmente
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Table(
                  defaultColumnWidth: FixedColumnWidth(150.0), // Largura das colunas
                  border: TableBorder.all(color: Colors.black),
                  children: [
                    TableRow(children: [
                      Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Data', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Título', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Empresa', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Aprovado', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Nota GOV', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Nota SOC', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Nota AMB', style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    // Popula a tabela com os dados da API
                    ...snapshot.data!.map((certificado) {
                      return TableRow(children: [
                        Text(certificado['id'].toString()),
                        Text(certificado['date']),
                        Text(certificado['tituloFormulario']),
                        Text(certificado['nomeEmpresa']),
                        Text(certificado['aprovado'] ? 'Sim' : 'Não'),
                        Text(certificado['nota_gov'].toString()),
                        Text(certificado['nota_soc'].toString()),
                        Text(certificado['nota_amb'].toString()),
                      ]);
                    }).toList(),
                  ],
                ),
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
    home: CertificadoPage(),
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}