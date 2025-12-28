import 'vinyl_model.dart';

class Reservation {
  final String id;
  final String status;
  final DateTime reservedAt;
  final DateTime expiresAt;

  final String? userName;
  final Vinyl? vinyl;

  Reservation({
    required this.id,
    required this.status,
    required this.reservedAt,
    required this.expiresAt,
    this.userName,
    this.vinyl,
  });

factory Reservation.fromJson(Map<String, dynamic> json) {
  Vinyl? vinyl;
  if (json['vinyl'] != null) {
    try {
      vinyl = Vinyl.fromJson(json['vinyl'] as Map<String, dynamic>);
    } catch (_) {
      // fallback jika ada field null, buat dummy Vinyl minimal
      final v = json['vinyl'] as Map<String, dynamic>;
      vinyl = Vinyl(
        id: v['_id'] as String,
        title: v['title'] as String? ?? 'Unknown',
        artist: v['artist'] as String? ?? '-',
        year: v['year'] != null ? (v['year'] as num).toInt() : null,
        price: v['price'] != null ? (v['price'] as num).toDouble() : 0.0,
        stock: v['stock'] != null ? (v['stock'] as num).toInt() : 0,
      );
    }
  }

  return Reservation(
    id: json['_id'] as String,
    status: json['status'] as String,
    reservedAt: DateTime.parse(json['reservedAt'] as String),
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    userName: json['user'] != null ? json['user']['username'] as String? : null,
    vinyl: vinyl,
  );
}
}