import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

import 'package:saga_flutter_app/pages/formulario/formulario_respostas.dart';
import 'package:saga_flutter_app/pages/formulario/formulario_visualizar_resp.dart';
import 'package:saga_flutter_app/widgets/MapDialog.dart';
// void downloadFileFromBase64(String base64Data, String fileName) {
//   final bytes = base64.decode(base64Data);
//   final blob = html.Blob([Uint8List.fromList(bytes)]);
//   final url = html.Url.createObjectUrlFromBlob(blob);
//   final anchor = html.AnchorElement(href: url)
//     ..setAttribute('download', fileName)
//     ..click();
//   html.Url.revokeObjectUrl(url);
// }

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
    final response = await http
        .get(Uri.parse("http://127.0.0.1:8080/certificado/$id/emitir"));

    if (response.statusCode == 200) {
      // Salvar o arquivo temporariamente antes de compartilhar
      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/certificado_$id.pdf');
      await file.writeAsBytes(bytes);

      // Criar um XFile para o compartilhamento
      final xFile = XFile(file.path);

      // Compartilhar o arquivo
      await Share.shareXFiles([xFile]);
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
        return const Color.fromARGB(255, 171, 155, 10);
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
        automaticallyImplyLeading: false,
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
                            certificado['nomeEmpresa'].toString() ?? '',
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
                            'Latitude: ${certificado['latitude'] ?? ''}',
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Longitude: ${certificado['longitude'] ?? ''}',
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final latitude = certificado['latitude'];
                              final longitude = certificado['longitude'];

                              if (latitude != null && longitude != null) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      contentPadding: EdgeInsets.zero,
                                      content: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            16.0), // Arredonda as bordas do AlertDialog
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.6,
                                          child: MapaDialog(
                                            latitude: double.parse(
                                                latitude.toString()),
                                            longitude: double.parse(
                                                longitude.toString()),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Coordenadas não disponíveis'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'Ver no Mapa',
                              style: TextStyle(color: Color(0xFF0F6FC6)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Titulo Formulário: ${certificado['tituloFormulario'] ?? ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceEvenly, // Distribui o espaço igualmente
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Centraliza os elementos verticalmente
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center, // Centraliza os textos horizontalmente
                                  children: [
                                    Text(
                                      'Nota Governança: ',
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: getBackgroundColor(
                                            certificado['nota_gov'].toString()),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        certificado['nota_gov'].toString() ==
                                                '1'
                                            ? 'Conforme'
                                            : certificado['nota_gov']
                                                        .toString() ==
                                                    '2'
                                                ? 'Médio'
                                                : 'Não conforme',
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign
                                            .center, // Centraliza o texto dentro do container
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 100,
                                width: 1,
                                child: ColoredBox(
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Nota Social: ',
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: getBackgroundColor(
                                            certificado['nota_soc'].toString()),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        certificado['nota_soc'].toString() ==
                                                '1'
                                            ? 'Conforme'
                                            : certificado['nota_soc']
                                                        .toString() ==
                                                    '2'
                                                ? 'Médio'
                                                : 'Não conforme',
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 100,
                                width: 1,
                                child: ColoredBox(
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Nota Ambiental: ',
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: getBackgroundColor(
                                            certificado['nota_amb'].toString()),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        certificado['nota_amb'].toString() ==
                                                '1'
                                            ? 'Conforme'
                                            : certificado['nota_amb']
                                                        .toString() ==
                                                    '2'
                                                ? 'Médio'
                                                : 'Não conforme',
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Status: ',
                                style: TextStyle(fontSize: 16),
                              ),
                              Expanded(
                                // Envolva o Container com Expanded para ocupar o espaço restante
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: getStatusBackgroundColor(
                                        certificado['status'].toString()),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    certificado['status'].toString() == 'true'
                                        ? 'Aprovado'
                                        : 'Reprovado',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (certificado['status'] == true)
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await apiService.downloadCertificado(
                                            certificado['id']);
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Erro ao baixar certificado: $e'),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Baixar Certificado',
                                      style:
                                          TextStyle(color: Color(0xFF0F6FC6)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                  width:
                                      10), // Adiciona espaçamento entre os botões
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FormularioRespostasVisuPage(
                                                certId: certificado['id']),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Visualizar Respostas',
                                    style: TextStyle(color: Color(0xFF0F6FC6)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          )
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
