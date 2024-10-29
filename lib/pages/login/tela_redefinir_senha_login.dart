import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saga_flutter_app/pages/login/tela_login.dart';
import 'cards.dart';
import 'generate_password.dart';

class ResetLoginPasswordPage extends StatelessWidget {
  final String email;

  ResetLoginPasswordPage({super.key, required this.email});

  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _validateAndSubmit(BuildContext context) async {
    final String password = _confirmPasswordController.text;

    print(password);

    try {
      final url =
          Uri.parse('http://186.226.48.222:8080/api/auth/reset-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        _showDialog(context, 'Sucesso', 'Senha redefinida com sucesso!', () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        });
      } else {
        final responseBody = jsonDecode(response.body);
        _showDialog(context, 'Erro',
            responseBody['message'] ?? 'Erro ao redefinir senha');
      }
    } catch (e) {
      _showDialog(
          context, 'Erro', 'Ocorreu um erro inesperado. Tente novamente.');
    }
  }

  void _showDialog(BuildContext context, String title, String message,
      [VoidCallback? onOkPressed]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onOkPressed != null) {
                  onOkPressed();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool _obscureConfirmPassword = true;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 40, left: 40, right: 40),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          "Redefinir Senha",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: email,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const GeneratePassword(),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Senha',
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: _obscureConfirmPassword),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _validateAndSubmit(context),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Color(0xFF0F6FC6)),
                              ),
                              child: const Text('Redefinir Senha',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
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
