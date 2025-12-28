class UserModel {
  final String id;
  final String username;
  final String role;
  final String? token;
  // final String password; // <-- tambahkan

  UserModel({
    required this.id,
    required this.username,
    required this.role,
    required this.token,
    // required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? "",
      username: json['username']  ?? "",
      role: json['role']  ?? "",
      token: json['token'],
      // password: json['password'] ?? "", // <-- tambahkan
    );
  }
}