import 'dart:convert';

import 'package:desafio_tec_flutter/screens/PasswordValidationResultScreen.dart';
import 'package:desafio_tec_flutter/services/GeneratePassword.dart';
import 'package:desafio_tec_flutter/services/PasswordValidator.dart';
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
  bool _isLoading = false;

  final PasswordValidator _passwordValidator = PasswordValidator();
  final GeneratePassword _generatePassword = GeneratePassword();

  Future<void> fetchRandomPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final senhaGerada = await _generatePassword.fetchPassword();
      setState(() {
        _passwordController.text = senhaGerada;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Senha gerada com sucesso!',
                style: TextStyle(color: Colors.white),
              ),
            backgroundColor: Colors.green,
          )
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao gerar senha, tente novamente',
                style: TextStyle(color: Colors.white),
              ),
            backgroundColor: Colors.red,
          )
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _validatePassword(String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _passwordValidator.validatePassword(password);

      if (result.containsKey('message') && result.containsKey('errors')) {
        List<String> errors = List<String>.from(result['errors'] ?? []);

        if (errors.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("A senha deve conter: ${errors.join(', ')}"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? "Senha inválida!"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else if (result.containsKey('message')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordValidationResultScreen(validationResult: result),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao validar senha."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset("images/login.png", width: 200, height: 200, fit: BoxFit.cover),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(bottom: 5, top: 5),
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "Fulano Almeida",
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),

                  Padding(
                    padding: EdgeInsets.only(bottom: 5, top: 5),
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "emailexample@gmail.com",
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),

                  Padding(
                    padding: EdgeInsets.only(bottom: 5, top: 5),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_senhaVisivel,
                      decoration: InputDecoration(
                        labelText: "Insira uma senha",
                        hintText: "********",
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _senhaVisivel = !_senhaVisivel;
                            });
                          },
                          icon: Icon(
                            _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: fetchRandomPassword,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)
                              )
                          ),
                          child: Text("Gerar Senha")
                      ),
                      ElevatedButton(
                          onPressed: () {
                            final senha = _passwordController.text;
                            _validatePassword(senha);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text("Verificar Senha", style: TextStyle(fontSize: 16),)
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
            ),
          ),
        ],
      ),
    );
  }
}
