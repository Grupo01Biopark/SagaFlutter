import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:saga_flutter_app/pages/user/user_editar.dart';

class ApiListUsuario {
  final String apiUrl = "http://138.186.234.48:8080/usuarios/listar";

  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));

    var utf8Response = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      var decodedData = json.decode(utf8Response);
      if (decodedData['users'] != null) {
        for (var user in decodedData['users']) {
          if (user['profileImage'] != null) {
            user['imageBytes'] = base64Decode(user['profileImage']);
          }
        }

        return decodedData['users'];
      } else {
        return [];
      }
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }
}

class UsuarioPage extends StatefulWidget {
  @override
  _UsuarioPageState createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  final ApiListUsuario apiService = ApiListUsuario();
  Future<List<dynamic>>? _futureUsuarios;

  @override
  void initState() {
    super.initState();
    _futureUsuarios = apiService.fetchData();
  }

  Future<void> deleteUser(String userId) async {
    final url = 'http://138.186.234.48:8080/usuarios/excluir/$userId';

    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        print('Usuário excluído com sucesso');
        setState(() {
          _futureUsuarios = apiService.fetchData();
        });
      } else {
        print('Falha ao excluir o usuário');
        print(response.body);
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listagem de Usuários'),
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureUsuarios,
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
                  var item = snapshot.data![index];
                  if (item["ativo"] == true) {
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
                            Row(
                              children: [
                                Center(
                                  child: CircleAvatar(
                                    backgroundImage: item['imageBytes'] != null
                                        ? MemoryImage(item['imageBytes'])
                                        : AssetImage(
                                                'assets/images/default_user_image.png')
                                            as ImageProvider,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  item['name'] ?? '',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Email: ${item['email'] ?? ''}',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Data de Cadastro: ${item['dataCadastro'] ?? ''}',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditUserPage(
                                          userId: item['id'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Confirmar Exclusão'),
                                          content: Text(
                                              'Tem certeza de que deseja excluir este usuário?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Fecha o modal
                                              },
                                              child: Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Fecha o modal
                                                deleteUser(item['id']
                                                    .toString()); // Substitua com o ID real do usuário
                                              },
                                              child: Text('Excluir'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
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
    home: UsuarioPage(),
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
