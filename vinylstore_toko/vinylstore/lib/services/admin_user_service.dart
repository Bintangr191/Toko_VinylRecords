import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/api_config.dart';

class AdminUserService {
  // ==============================
  // GET USERS
  // ==============================
  static Future<List<UserModel>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token"); 
    if (token == null) throw Exception("Token tidak ditemukan. Harap login ulang.");

    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl()}/admin/users"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Gagal load user. Status: ${res.statusCode}");
    }

    final List list = jsonDecode(res.body);
    return list.map((e) => UserModel.fromJson(e)).toList();
  }

  // ==============================
  // UPDATE ROLE
  // ==============================
  static Future<bool> updateRole(String userId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final currentUserId = prefs.getString("userId");

    if (token == null) throw Exception("Token tidak ditemukan. Harap login ulang.");
    if (userId == currentUserId) throw Exception("Tidak bisa mengubah role sendiri");

    final res = await http.put(
      Uri.parse("${ApiConfig.baseUrl()}/admin/users/$userId/role"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"role": role}),
    );

    return res.statusCode == 200;
  }

  // ==============================
  // DELETE USER
  // ==============================
  static Future<bool> deleteUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final currentUserId = prefs.getString("userId");

    if (token == null) throw Exception("Token tidak ditemukan. Harap login ulang.");
    if (userId == currentUserId) throw Exception("Tidak bisa menghapus akun sendiri");

    final res = await http.delete(
      Uri.parse("${ApiConfig.baseUrl()}/admin/users/$userId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return res.statusCode == 200;
  }
}