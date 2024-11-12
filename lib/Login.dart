import 'dart:convert';

import 'package:desafio_tec_flutter/PasswordValidator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _senhaVisivel = false;
  String _passwordStrengthMessage = "";
  Color _passwordStrengthColor = Colors.red;
  List<String> _missingCriteria = [];

  final PasswordValidator _passwordValidator = PasswordValidator();

  Future<void> fetchRandomPassword() async {
  final url = Uri.parse('https://desafioflutter-api.modelviewlabs.com/random');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final senhaGerada = data['password'];

      setState(() {
        _passwordController.text = senhaGerada;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Senha gerada com sucesso!')),
      );

    } else {
      throw Exception('Erro ao Gerar senha');
    }
  } catch (e) {
      print('Erro na requisição: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar senha')),
      );
    }
  }

  Future<void> _validatePassword(String password) async {
    try {
      final result = await _passwordValidator.validatePassword(password);

      if (result.containsKey('message') && result.containsKey('errors')) {
        List<String> errors = List<String>.from(result['errors'] ?? []);

        if (errors.isNotEmpty) {
          setState(() {
            _missingCriteria = errors;
            _passwordStrengthMessage = "A senha deve conter: ${_missingCriteria.join(', ')}";
            _passwordStrengthColor = Colors.red;
          });
        } else {
          setState(() {
            _passwordStrengthMessage = result['message'] ?? "Senha inválida!";
            _passwordStrengthColor = Colors.red;
          });
        }
      } else if (result.containsKey('message')) {
        setState(() {
          _missingCriteria.clear();
          _passwordStrengthMessage = "Senha forte!";
          _passwordStrengthColor = Colors.green;
        });
      } else {
        setState(() {
          _passwordStrengthMessage = "Erro inesperado ao validar senha.";
          _passwordStrengthColor = Colors.red;
        });
      }

    } catch (e) {
      print("Erro ao validar senha: $e");
      setState(() {
        _passwordStrengthMessage = "Erro ao validar senha.";
        _passwordStrengthColor = Colors.red;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gerador de senha"),
      ),
      body: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Image.asset("images/login.png"),
              TextField(
                enabled: false,
                decoration: InputDecoration(
                    labelText: "Fulano Almeida"
                ),
              ),
              TextField(
                enabled: false,
                decoration: InputDecoration(
                    labelText: "emailexample@gmail.com"
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: !_senhaVisivel,
                decoration: InputDecoration(
                labelText: "Insira uma senha",
                hintText: "********",
                // border: OutlineInputBorder(),
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _senhaVisivel = !_senhaVisivel;
                      });
                    },
                    icon: Icon(
                      _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                    ))
              ),
              ),
              Text(
                _passwordStrengthMessage,
                style: TextStyle(color: _passwordStrengthColor),
              ),
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: fetchRandomPassword,
                        child: Text("Gerar Senha")
                    ),
                    ElevatedButton(
                        onPressed: () {
                          final senha = _passwordController.text;
                          _validatePassword(senha);
                        },
                        child: Text("Verificar Senha")
                    )
                  ],
                ),
              )

            ],
          ),
        )
      ),
    );
  }
}
