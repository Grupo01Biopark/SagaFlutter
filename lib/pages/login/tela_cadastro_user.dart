import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saga_flutter_app/pages/login/generate_password.dart';
import 'package:saga_flutter_app/pages/login/tela_login.dart';
import 'package:http/http.dart' as http;
import 'package:saga_flutter_app/pages/user/user.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'cards.dart';

class RegistrationUser extends StatefulWidget {
  const RegistrationUser({super.key});

  @override
  _RegistrationUserState createState() => _RegistrationUserState();
}

class _RegistrationUserState extends State<RegistrationUser> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureConfirmPassword = true;
  File? _profileImage;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    }
  }

  void _showDialog(String title, String content, [VoidCallback? onConfirm]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onConfirm != null) {
                  onConfirm();
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _validateAndSubmit() async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String? validationMessage = _validateEmail(email);
    if (validationMessage != null) {
      _showDialog('Erro', validationMessage);
    } else {
      String? base64Image;
    if (_profileImage != null && !kIsWeb) {
      base64Image = base64Encode(_profileImage!.readAsBytesSync());
    } else if (_webImage != null && kIsWeb) {
      base64Image = base64Encode(_webImage!);
    }



      final url = Uri.parse('http://127.0.0.1:8080/api/auth/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': _confirmPasswordController.text,
          'profileImage': base64Image,
        }),
      );

      // Processar a resposta do servidor
      if (response.statusCode == 200) {
        _showDialog('Cadastro Realizado', 'Cadastro realizado com sucesso!',
            () {
          Navigator.of(context).pushReplacementNamed('/usuario');
        });
      } else if (response.statusCode == 400) {
        final responseBody = jsonDecode(response.body);
        _showDialog('Erro', responseBody['message'] ?? 'Erro ao registrar');
      } else {
        print(response.body);
        _showDialog('Erro', response.body);
      }
    }
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'O e-mail não pode estar vazio.';
    }
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(email)) {
      return 'Por favor, insira um e-mail válido.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 150;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 40, left: 40, right: 40),
        child: SingleChildScrollView(
          // Adicionado SingleChildScrollView
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .stretch, // Garante que o conteúdo se estenda
                    children: [
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          "Cadastro de Usuário",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      if (_profileImage != null && !kIsWeb)
                        CircleAvatar(
                          radius:
                              avatarSize / 2, // O radius é metade do diâmetro
                          backgroundImage: FileImage(
                            _profileImage!,
                          ),
                          backgroundColor:
                              Colors.grey, // Cor de fundo caso não tenha imagem
                        ),

                      if (_webImage != null && kIsWeb)
                        CircleAvatar(
                          radius: avatarSize / 2,
                          backgroundImage: MemoryImage(
                            _webImage!,
                          ),
                          backgroundColor:
                              Colors.grey, // Cor de fundo caso não tenha imagem
                        ),
                        const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.image),
                            label: Text('Selecionar Imagem'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(),
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                      ),
                      const SizedBox(height: 16),
                      // Botão para selecionar imagem
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _validateAndSubmit,
                              child: const Text(
                                'Cadastrar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0F6FC6),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 22),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
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
