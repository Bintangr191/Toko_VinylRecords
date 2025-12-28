import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
static const _tokenKey = "auth_token";
static const _roleKey = "auth_role";
static const _userIdKey = "auth_user_id";
static const _usernameKey = "auth_username";

/// =========================
/// SAVE
/// =========================
static Future<void> saveAuth({
required String token,
required String role,
required String userId,
required String username,
}) async {
final prefs = await SharedPreferences.getInstance();
await prefs.setString(_tokenKey, token);
await prefs.setString(_roleKey, role);
await prefs.setString(_userIdKey, userId);
await prefs.setString(_usernameKey, username);
}

/// =========================
/// GETTERS
/// =========================
static Future<String?> getToken() async {
final prefs = await SharedPreferences.getInstance();
return prefs.getString(_tokenKey);
}

static Future<String?> getRole() async {
final prefs = await SharedPreferences.getInstance();
return prefs.getString(_roleKey);
}

static Future<String?> getUserId() async {
final prefs = await SharedPreferences.getInstance();
return prefs.getString(_userIdKey);
}

static Future<String?> getUsername() async {
final prefs = await SharedPreferences.getInstance();
return prefs.getString(_usernameKey);
}

/// =========================
/// CHECK LOGIN
/// =========================
static Future<bool> isLoggedIn() async {
final token = await getToken();
return token != null && token.isNotEmpty;
}

static Future<bool> isAdmin() async {
final role = await getRole();
return role == "admin";
}

/// =========================
/// LOGOUT
/// =========================
static Future<void> logout() async {
final prefs = await SharedPreferences.getInstance();
await prefs.remove(_tokenKey);
await prefs.remove(_roleKey);
await prefs.remove(_userIdKey);
await prefs.remove(_usernameKey);
}
}

