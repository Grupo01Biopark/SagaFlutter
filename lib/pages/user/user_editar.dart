import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditUserPage extends StatefulWidget {
  final int userId;

  EditUserPage({required this.userId});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  Uint8List? _webImage;
  String? _profileImageBase64;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final response = await http.get(
      Uri.parse("http://127.0.0.1:8080/usuarios/listar/${widget.userId}"),
    );

    if (response.statusCode == 200) {
      var utf8Response = utf8.decode(response.bodyBytes);
      var userData = json.decode(utf8Response);

      setState(() {
        _nameController.text = userData['user']['name'];
        _emailController.text = userData['user']['email'];
        _profileImageBase64 = userData['user']['profileImage'];
      });
    } else {
      throw Exception('Falha ao carregar dados do usuário');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _profileImageBase64 = base64Encode(bytes);
        });
      } else {
        setState(() {
          _profileImage = File(pickedFile.path);
          _profileImageBase64 = base64Encode(_profileImage!.readAsBytesSync());
        });
      }
    }
  }

  Future<void> _editUser() async {
    if (_formKey.currentState!.validate()) {
      final apiUrl = "http://127.0.0.1:8080/usuarios/editar/${widget.userId}";

      Map<String, dynamic> userData = {
        "name": _nameController.text,
        "email": _emailController.text,
        "profileImage": _profileImageBase64,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário editado com sucesso!')),
        );
        Navigator.of(context).pushReplacementNamed('/usuario');
      } else {
        var utf8Response = utf8.decode(response.bodyBytes);
        var responseJson = json.decode(utf8Response);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseJson['message'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 150;
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              Center(
                child: CircleAvatar(
                  radius: avatarSize / 2,
                  backgroundImage: _webImage != null && kIsWeb
                      ? MemoryImage(_webImage!)
                      : _profileImage != null
                          ? FileImage(_profileImage!) as ImageProvider
                          : (_profileImageBase64 != null
                              ? MemoryImage(
                                  base64Decode(_profileImageBase64!),
                                )
                              : AssetImage('assets/images/default_user_image.png')),
                  backgroundColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('Selecionar Imagem'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _editUser,
                child: Text(
                  'Editar Usuário',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F6FC6),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
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
