import 'package:flutter/material.dart';
import 'package:saga_flutter_app/pages/login/email_validator.dart';
import 'package:saga_flutter_app/pages/login/tela_login.dart';

import 'cards.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

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
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('E-mail Enviado'),
                              content: const Text(
                                  'A senha foi enviada para o e-mail informado.'),
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
                        // Continue com o processo de recuperação de senha
                      }
                    },
                    child: const Text("Solicitar E-mail"),
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
