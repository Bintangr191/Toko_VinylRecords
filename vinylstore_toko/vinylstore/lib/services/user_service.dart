import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_config.dart';
import '../models/user_model.dart';

class UserService {
  static String get _base => "${ApiConfig.baseUrl()}/users";

  // =========================
  // GET PROFILE
  // =========================
  static Future<UserModel> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("Token tidak ditemukan");
    }

    final res = await http.get(
      Uri.parse("$_base/me"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Gagal memuat profil (${res.statusCode})");
    }

    final data = jsonDecode(res.body);
    return UserModel.fromJson(data);
  }

  // =========================
  // UPDATE USERNAME
  // =========================
  static Future<bool> updateUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return false;

    final res = await http.put(
      Uri.parse("$_base/profile"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": username,
      }),
    );

    return res.statusCode == 200;
  }

  // =========================
  // UPDATE PASSWORD
  // =========================
  static Future<bool> updatePassword(
    String oldPassword,
    String newPassword,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return false;

    final res = await http.put(
      Uri.parse("$_base/password"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      }),
    );

    return res.statusCode == 200;
  }

  // =========================
  // LOGOUT
  // =========================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}