import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  final String baseUrl = "http://localhost:8080/pos/auth/login";

  Future<UserModel> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return UserModel.fromJson(jsonData);
    } else {
      throw Exception('Error en la autenticación');
    }
  }
}
