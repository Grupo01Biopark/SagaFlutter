import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:saga_flutter_app/pages/login/generate_password.dart';

import 'cards.dart';

class RegistrationUser extends StatefulWidget {
  const RegistrationUser({super.key});

  @override
  _RegistrationUserState createState() => _RegistrationUserState();
}

class _RegistrationUserState extends State<RegistrationUser> {
  Uint8List? _imageData;
  String? _imageName;
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureConfirmPassword = true;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final name = basename(pickedFile.path);

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
                              //colocar uma imagem padrão de ava
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
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const GeneratePassword(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      keyboardType: TextInputType.text,
                      obscureText: _obscureConfirmPassword,
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
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Lógica de cadastro aqui
                            },
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
