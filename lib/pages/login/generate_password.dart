import 'dart:math';

import 'package:flutter/material.dart';

class GeneratePassword extends StatefulWidget {
  const GeneratePassword({super.key});

  @override
  _GeneratePasswordState createState() => _GeneratePasswordState();
}

class _GeneratePasswordState extends State<GeneratePassword> {
  final TextEditingController password = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String tooltipMessage = 'Gere uma nova ';
  bool obscureText = true;
  static String passwordStrengthMessage = 'Nível da Senha';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        tooltipMessage =
            _focusNode.hasFocus ? 'Digite uma Senha' : 'Digite uma Senha';
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: password,
            focusNode: _focusNode,
            obscureText: obscureText,
            onChanged: (text) {
              setState(() {
                _buildPasswordStrengthIcon();
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              label: Tooltip(
                message: tooltipMessage,
                child: Text(
                  tooltipMessage,
                  key: const Key('tooltip_message'),
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message: passwordStrengthMessage,
                    child: IconButton(
                      icon: _buildPasswordStrengthIcon(),
                      onPressed: null,
                    ),
                  ),
                  Tooltip(
                    message: 'Gerar Senha',
                    child: IconButton(
                      icon: const Icon(Icons.generating_tokens_outlined),
                      onPressed: () {
                        generateAndUpdatePassword();
                      },
                    ),
                  ),
                  Tooltip(
                    message: 'Visualizar Senha',
                    child: IconButton(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void generateAndUpdatePassword() {
    const String characters =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$&*~";
    Random random = Random.secure();
    password.text = List.generate(20, (index) {
      return characters[random.nextInt(characters.length)];
    }).join();
  }

  Widget _buildPasswordStrengthIcon() {
    int passwordLength = password.text.length;
    IconData iconData;
    Color iconColor;

    if (passwordLength < 6) {
      iconData = Icons.error_outline;
      iconColor = Colors.red;
      passwordStrengthMessage = 'Senha Muito Fraca';
    } else if (passwordLength < 8) {
      iconData = Icons.warning;
      iconColor = Colors.orange;
      passwordStrengthMessage = 'Senha Fraca';
    } else if (passwordLength < 12) {
      iconData = Icons.check_circle_outline;
      iconColor = Colors.yellow;
      passwordStrengthMessage = 'Senha Média';
    } else if (passwordLength < 16) {
      iconData = Icons.verified_outlined;
      iconColor = Colors.green;
      passwordStrengthMessage = 'Senha Forte';
    } else {
      iconData = Icons.lock;
      iconColor = Colors.blue;
      passwordStrengthMessage = 'Senha Muito Forte';
    }

    return Icon(
      iconData,
      color: iconColor,
    );
  }
}
