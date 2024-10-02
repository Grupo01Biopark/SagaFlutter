import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:saga_flutter_app/pages/user/user_model.dart';
import 'package:saga_flutter_app/pages/user/user_provider.dart';
import 'cards.dart';
import 'tela_resetar_senha.dart';
import 'tela_cadastro_user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscureText = true;

  // Função para fazer login via API
  Future<void> loginUser() async {
    final String email = emailController.text;
    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showErrorDialog("Por favor, insira seu email e senha.");
      return;
    }

    final url = Uri.parse('http://127.0.0.1:8080/api/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      try {
        // Tente analisar a resposta como JSON
        final userData = jsonDecode(response.body);
        final user = UserModel.fromJson(userData);

        final Map<String, dynamic> responseBody = json.decode(response.body);

       
        final bool tagAlterarSenha = responseBody['tagAlterarSenha'];

        if (tagAlterarSenha == true) {
          print("bora setar a senha");
        }else{
        
        Provider.of<UserProvider>(context, listen: false).setUser(user);

        Navigator.of(context).pushReplacementNamed('/dashboard');
      }

      } catch (e) {
        // Se a resposta não for JSON, trate-a como texto simples
        if (response.body == "Login successful!") {
          // Login bem-sucedido, mas sem dados do usuário
          Navigator.of(context).pushReplacementNamed('/dashboard');
        } else {
          // Exibir mensagem de erro
          showErrorDialog("Resposta inesperada da API.");
        }
      }
    } else {
      // Login falhou, exibir mensagem de erro
      showErrorDialog("Email ou senha inválidos. Tente novamente.");
    }
  }

  // Exibe diálogo de erro
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Erro"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  Center(
                    child: Image.asset(
                      'assets/images/Logo_saga.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const Center(
                    child: Text(
                      "ENTRAR",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        // fontFamily: ,
                        fontSize: 28,
                        letterSpacing: 1.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "Bem vindo de volta! Por favor, insira seus dados de login.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
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
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(fontSize: 20),
                  ),
                  Container(
                    height: 40,
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: const Text(
                        "Esqueci a senha",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color.fromARGB(255, 54, 181, 255),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ResetPasswordPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    height: 60,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F6FC6),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: SizedBox.expand(
                      child: TextButton(
                        onPressed: () {
                          loginUser(); // Chamada para a função de login
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF0F6FC6),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Entrar",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: TextButton(
                      child: const Text(
                        "Cadastre-se",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 54, 181, 255),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationUser(),
                          ),
                        );
                      },
                    ),
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