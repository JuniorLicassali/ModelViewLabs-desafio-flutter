import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GeneratePassword {
  Future<String> fetchPassword() async {
    try {
      final response = await http.get(Uri.parse('https://desafioflutter-api.modelviewlabs.com/random'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['password'];
      }
      throw Exception('Erro ao gerar senha');
    } catch (e) {
      throw Exception('Erro na requisição');
    }
  }
}