import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Adiciona o pacote HTTP
import 'package:saga_flutter_app/pages/login/email_validator.dart';
import 'package:saga_flutter_app/pages/login/tela_login.dart';
import 'cards.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    Future<void> sendPasswordResetRequest(String email) async {
      final String apiUrl =
          'http://138.186.234.48:8080/api/auth/forgot-password';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
          }),
        );

        if (response.statusCode == 200) {
          // Se a API retornar sucesso, exibe o diálogo de confirmação
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('E-mail Enviado'),
                content:
                    const Text('A senha foi enviada para o e-mail informado.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text('Confirmar'),
                  ),
                ],
              );
            },
          );
        } else {
          // Se a API retornar erro, exibe uma mensagem de erro
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Erro'),
                content: const Text(
                    'Ocorreu um erro ao tentar recuperar a senha. Verifique o e-mail e tente novamente.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Confirmar'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        // Exibe um diálogo em caso de erro na comunicação com o servidor
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erro de Conexão'),
              content: const Text(
                  'Não foi possível se conectar ao servidor. Tente novamente mais tarde.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      }
    }

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 60, left: 40, right: 40),
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 40),
            CustomCard(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/Logo_saga.png',
                    width: 200,
                    height: 200,
                  ),
                  const Text(
                    "Recuperar Senha",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "E-mail",
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final String? validationMessage =
                          EmailValidator.validateEmail(emailController.text);
                      if (validationMessage != null) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Erro'),
                              content: Text(validationMessage),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Confirmar'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // Faz a chamada à API para solicitar a recuperação de senha
                        sendPasswordResetRequest(emailController.text);
                      }
                    },
                    child: const Text("Solicitar E-mail",
                        style: TextStyle(color: Color(0xFF0F6FC6))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
