class Vinyl {
  /// MongoDB _id → HARUS non-null
  final String id;

  final String title;
  final String artist;
  final int? year;
  final double price;
  final int stock;

  final String? genre;
  final String? description;
  final String? coverUrl;
  final String? audioUrl;

  Vinyl({
    required this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.price,
    required this.stock,
    this.genre,
    this.description,
    this.coverUrl,
    this.audioUrl,
  });

  /// FROM BACKEND (MongoDB)
    factory Vinyl.fromJson(Map<String, dynamic> json) {
      return Vinyl(
        id: json['_id'] as String,
        title: json['title'] as String,
        artist: json['artist'] as String,
        year: json['year'] != null ? (json['year'] as num).toInt() : null,
        price: (json['price'] as num).toDouble(),
        stock: (json['stock'] as num).toInt(),
        genre: json['genre'] as String?,
        description: json['description'] as String?,
        coverUrl: json['coverUrl'] as String?,
        audioUrl: json['audioUrl'] as String?,
      );
    }

  /// TO BACKEND (CREATE / UPDATE)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'year': year,
      'price': price,
      'stock': stock,
      'genre': genre,
      'description': description,
      'coverUrl': coverUrl,
      'audioUrl': audioUrl,
    };
  }
}
