import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  static const String baseUrl = "http://localhost:3000";

  // ================================
  // LOGIN
  // ================================
  static Future<UserModel?> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/auth/login");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      final user = UserModel.fromJson({
        ...data["user"],
        "token": data["token"],
      });

      
      await StorageService.saveToken(user.token!);

      return user;
    }

    return null;
  }

  // ================================
  // REGISTER
  // ================================
  static Future<bool> register(
      String username, String password, String role) async {
    final url = Uri.parse("$baseUrl/auth/register");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
        "role": role,
      }),
    );

    return res.statusCode == 201;
  }
}
