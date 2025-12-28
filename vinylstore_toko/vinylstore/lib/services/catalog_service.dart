import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vinyl_model.dart';
import '../models/reservation_model.dart';
import '../utils/api_config.dart';

class CatalogService {
  static const _base = "http://localhost:3000/vinyl";
  static const _reservation = "http://localhost:3000/reservations";
  static const wishlistUrl = "http://localhost:3000/wishlist";
  // static const _adminReservations = "http://localhost:3000/admin/reservations";
  static String get _adminReservations => "${ApiConfig.baseUrl()}/admin/reservations";

  // =============================
  // GET ALL VINYL
  // =============================
  static Future<List<Vinyl>> getCatalog() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) throw Exception("Token is null");

    final res = await http.get(
      Uri.parse(_base),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load catalog: ${res.statusCode}");
    }

    final data = jsonDecode(res.body) as List;
    return data.map((e) => Vinyl.fromJson(e)).toList();
  }

  // =============================
  // GET VINYL DETAIL
  // =============================
  static Future<Vinyl> getDetail(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) throw Exception("Token is null");

    final res = await http.get(
      Uri.parse("$_base/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load vinyl detail: ${res.statusCode}");
    }

    return Vinyl.fromJson(jsonDecode(res.body));
  }

  // =============================
  // KEEP / RESERVE VINYL
  // =============================
  static Future<bool> keepVinyl(String vinylId, String confirmTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    final res = await http.post(
      Uri.parse("$_reservation/keep/$vinylId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "confirmTitle": confirmTitle, 
      }),
    );

    return res.statusCode == 200;
  }

  // =============================
  // CANCEL RESERVATION
  // =============================
  static Future<bool> cancelReservation(String vinylId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    final res = await http.delete(
      Uri.parse("$_reservation/cancel/$vinylId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    return res.statusCode == 200;
  }

  // =============================
  // CHECK RESERVED
  // =============================
  static Future<String?> isReserved(String vinylId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return null;

    final res = await http.get(
      Uri.parse("$_reservation/my"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body) as List;

    try {
      final reservation = data.firstWhere(
        (r) =>
            r['vinyl'] != null &&
            r['vinyl']['_id'] == vinylId &&
            r['status'] == 'active',
      );
      return reservation['_id'];
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getReservationStatus(String vinylId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");
  if (token == null) return null;

  final res = await http.get(
    Uri.parse("$_reservation/my"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  if (res.statusCode != 200) return null;

  final List data = jsonDecode(res.body);

  try {
    final reservation = data.firstWhere(
      (r) => r['vinyl'] != null && r['vinyl']['_id'] == vinylId,
    );

    return reservation['status']; 
  } catch (_) {
    return null;
  }
}



  // =============================
  // TOGGLE WISHLIST
  static Future<bool> toggleWishlist(String vinylId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  final res = await http.post(
    Uri.parse("$wishlistUrl/$vinylId"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  final data = jsonDecode(res.body);
  return data["wishlisted"] == true;
}



static Future<bool> isWishlisted(String vinylId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  final res = await http.get(
    Uri.parse("$wishlistUrl/check/$vinylId"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  final data = jsonDecode(res.body);
  return data["wishlisted"] == true;
}

static Future<List<Vinyl>> getMyWishlist() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  final res = await http.get(
    Uri.parse("$wishlistUrl/my"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  final data = jsonDecode(res.body) as List;
  return data
      .where((e) => e["vinyl"] != null) 
      .map((e) => Vinyl.fromJson(e["vinyl"]))
      .toList();
}

  // =============================
  // ADMIN: GET ALL RESERVATIONS
  // =============================
  static Future<List<Reservation>> getAllReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token"); 

    if (token == null) {
      throw Exception("Token admin tidak ditemukan");
    }

    final res = await http.get(
      Uri.parse(_adminReservations),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode != 200) {
      throw Exception(
        "Gagal memuat reservasi (${res.statusCode}): ${res.body}",
      );
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Reservation.fromJson(e)).toList();
  }

  // =============================
  // ADMIN: UPDATE STATUS RESERVASI
  // =============================
  static Future<bool> updateReservationStatus(String reservationId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return false;

    final res = await http.patch(
      Uri.parse("$_adminReservations/$reservationId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"status": status}),
    );

    return res.statusCode == 200;
  }
}