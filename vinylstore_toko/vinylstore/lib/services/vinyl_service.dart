import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vinyl_model.dart';

class VinylService {
  static const baseUrl = "http://localhost:3000/vinyl";

  // -----------------------------
  // GET ALL VINYL
  // -----------------------------
  static Future<List<Vinyl>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(res.body) as List;
    return data.map((e) => Vinyl.fromJson(e)).toList();
  }

  // -----------------------------
  // DELETE
  // -----------------------------
  static Future<bool> deleteVinyl(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return res.statusCode == 200;
  }

// -----------------------------
// CREATE / UPDATE VINYL
// -----------------------------
static Future<bool> saveVinyl({
  String? id,
  required String title,
  required String artist,
  required int year,
  required double price,
  required int stock,
  String? genre,           
  String? description,     
  Uint8List? coverBytes,
  Uint8List? audioBytes,
  String? coverName,
  String? audioName,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  final url = Uri.parse(id == null ? baseUrl : "$baseUrl/$id");
  var request = http.MultipartRequest(id == null ? "POST" : "PUT", url);
  request.headers["Authorization"] = "Bearer $token";

  request.fields["title"] = title;
  request.fields["artist"] = artist;
  request.fields["year"] = year.toString();
  request.fields["price"] = price.toString();
  request.fields["stock"] = stock.toString();

  if (genre != null) request.fields["genre"] = genre;
  if (description != null) request.fields["description"] = description;

  if (coverBytes != null && coverName != null) {
    request.files.add(
      http.MultipartFile.fromBytes(
        "cover",
        coverBytes,
        filename: coverName,
      ),
    );
  }

  if (audioBytes != null && audioName != null) {
    request.files.add(
      http.MultipartFile.fromBytes(
        "audio",
        audioBytes,
        filename: audioName,
      ),
    );
  }

  final res = await request.send();
  return res.statusCode == 200 || res.statusCode == 201;
}

// -----------------------------
// KEEP / RESERVE VINYL
// -----------------------------
static Future<bool> keepVinyl(String vinylId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  final res = await http.post(
    Uri.parse("http://localhost:3000/reservation/keep/$vinylId"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  return res.statusCode == 200;
}

// -----------------------------
// CHECK RESERVATION STATUS
// -----------------------------
static Future<bool> isReserved(String vinylId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  final res = await http.get(
    Uri.parse("http://localhost:3000/reservation/status/$vinylId"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  if (res.statusCode != 200) return false;
  final data = jsonDecode(res.body);
  return data['reserved'] == true;
}

// -----------------------------
// CANCEL RESERVATION
// -----------------------------
static Future<bool> cancelReservation(String vinylId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  final res = await http.delete(
    Uri.parse("http://localhost:3000/reservation/cancel/$vinylId"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  return res.statusCode == 200;
}
}