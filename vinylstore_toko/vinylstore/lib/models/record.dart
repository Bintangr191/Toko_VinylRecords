// class Record {
//   String? id;
//   String judul;
//   String artis;
//   int tahun;
//   String genre;
//   int harga;
//   int stock;     // tetap pakai 'stock' di Dart
//   String? cover;
//   String? deskripsi;

//   Record({
//     this.id,
//     required this.judul,
//     required this.artis,
//     required this.tahun,
//     required this.genre,
//     required this.harga,
//     required this.stock,
//     this.cover,
//     this.deskripsi,
//   });

//   factory Record.fromJson(Map<String, dynamic> json) {
//     return Record(
//       id: json['_id'] as String?,
//       judul: json['judul'] as String? ?? '',
//       artis: json['artis'] as String? ?? '',
//       tahun: (json['tahun'] is int) ? json['tahun'] : int.parse(json['tahun'].toString()),
//       genre: json['genre'] as String? ?? '',
//       harga: (json['harga'] is int) ? json['harga'] : int.parse(json['harga'].toString()),
//       stock: (json['stok'] is int) ? json['stok'] : int.parse(json['stok'].toString()), // map dari 'stok'
//       cover: json['cover'] as String?,
//       deskripsi: json['deskripsi'] as String?,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "judul": judul,
//       "artis": artis,
//       "tahun": tahun,
//       "genre": genre,
//       "harga": harga,
//       "stok": stock,         // map ke 'stok' untuk backend
//       "cover": cover,
//       "deskripsi": deskripsi,
//     };
//   }
// }