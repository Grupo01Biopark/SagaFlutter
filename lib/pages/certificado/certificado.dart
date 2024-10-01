import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

void downloadFileFromBase64(String base64Data, String fileName) {
  final bytes = base64.decode(base64Data);
  final blob = html.Blob([Uint8List.fromList(bytes)]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}

class ApiCertificadoListService {
  final String apiUrl = "http://127.0.0.1:8080/certificado/listar";

  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['certificados'];
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }

  Future<void> downloadCertificado(int id) async {
    final response = await http.get(Uri.parse("http://127.0.0.1:8080/certificado/$id/emitir"));

    if (response.statusCode == 200) {
      final base64Data = base64.encode(response.bodyBytes);
      downloadFileFromBase64(base64Data, "certificado_$id.pdf");
    } else {
      throw Exception('Falha ao baixar certificado');
    }
  }
}

class CertificadoPage extends StatelessWidget {
  final ApiCertificadoListService apiService = ApiCertificadoListService();

  Color getBackgroundColor(String nota) {
    switch (nota) {
      case '1':
        return Colors.green;
      case '2':
        return Colors.yellow;
      case '3':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getStatusBackgroundColor(String status) {
    return status == 'true' ? Colors.green : Colors.red;
  }

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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var certificado = snapshot.data![index];
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
                            certificado['id'].toString() ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Data: ${certificado['date'] ?? ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Titulo Formulário: ${certificado['tituloFormulario'] ?? ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Nome da Empresa: ${certificado['nomeEmpresa'] ?? ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Nota Governança: '),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: getBackgroundColor(certificado['nota_gov'].toString()),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  certificado['nota_gov'].toString() == '1'
                                      ? 'Conforme'
                                      : certificado['nota_gov'].toString() == '2'
                                          ? 'Médio'
                                          : 'Não conforme',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Nota Social: '),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: getBackgroundColor(certificado['nota_soc'].toString()),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  certificado['nota_soc'].toString() == '1'
                                      ? 'Conforme'
                                      : certificado['nota_soc'].toString() == '2'
                                          ? 'Médio'
                                          : 'Não conforme',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Nota Ambiental: '),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: getBackgroundColor(certificado['nota_amb'].toString()),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  certificado['nota_amb'].toString() == '1'
                                      ? 'Conforme'
                                      : certificado['nota_amb'].toString() == '2'
                                          ? 'Médio'
                                          : 'Não conforme',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Status: '),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: getStatusBackgroundColor(certificado['status'].toString()),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  certificado['status'].toString() == 'true'
                                      ? 'Aprovado'
                                      : 'Reprovado',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await apiService.downloadCertificado(certificado['id']);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro ao baixar certificado: $e')),
                                );
                              }
                            },
                            child: Text('Baixar Certificado'),
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