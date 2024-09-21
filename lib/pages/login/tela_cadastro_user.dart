import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:saga_flutter_app/pages/login/generate_password.dart';
import 'package:saga_flutter_app/pages/login/tela_login.dart';

import 'cards.dart';

class RegistrationUser extends StatefulWidget {
  const RegistrationUser({super.key});

  @override
  _RegistrationUserState createState() => _RegistrationUserState();
}

class _RegistrationUserState extends State<RegistrationUser> {
  Uint8List? _imageData;
  String? _imageName;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureConfirmPassword = true;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final name = p.basename(pickedFile.path);

        setState(() {
          _imageData = bytes;
          _imageName = name;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error picking image: $e");
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

  void _validateAndSubmit() {
    final String email = _emailController.text;
    final String? validationMessage = _validateEmail(email);

    if (validationMessage != null) {
      _showDialog('Erro', validationMessage);
    } else {
      _showDialog('Cadastro Realizado', 'Cadastro realizado com sucesso!', () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      });
      // Continue com o processo de cadastro
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 40, left: 40, right: 40),
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
                        "Cadastro de Usuário",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: _imageData == null
                          ? Image.asset(
                              'assets/images/Logo_saga.png',
                              width: 150,
                              height: 150,
                            )
                          : Image.memory(
                              _imageData!,
                              width: 150,
                              height: 150,
                            ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Imagem Perfil'),
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
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _validateAndSubmit,
                            child: const Text('Cadastrar'),
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
    );
  }
}
