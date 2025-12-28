import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  UserModel? user;
  bool loading = true;

  final usernameController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  bool canSaveUsername = false;
  bool canChangePassword = false;
  bool obscureOldPassword = true;
  bool obscureNewPassword = true;

  @override
  void initState() {
    super.initState();
    loadProfile();

    // Listener untuk cek perubahan username
    usernameController.addListener(() {
      final changed = user != null && usernameController.text.trim() != user!.username;
      setState(() {
        canSaveUsername = changed && usernameController.text.trim().length >= 3;
      });
    });

    // Listener untuk cek perubahan password
    void passwordListener() {
      final oldPass = oldPasswordController.text;
      final newPass = newPasswordController.text;
      setState(() {
        canChangePassword =
            oldPass.isNotEmpty &&
            newPass.isNotEmpty &&
            newPass.length >= 6 &&
            oldPass != newPass;
      });
    }

    oldPasswordController.addListener(passwordListener);
    newPasswordController.addListener(passwordListener);
  }

  Future<void> loadProfile() async {
    try {
      final data = await UserService.getProfile();
      user = data;
      usernameController.text = data.username;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Gagal memuat profil"),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
    setState(() => loading = false);
  }

  // ======================
  // UPDATE USERNAME
  // ======================
  Future<void> saveUsername() async {
    if (!canSaveUsername) return;

    final username = usernameController.text.trim();

    final success = await UserService.updateUsername(username);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Username berhasil diperbarui"),
            backgroundColor: Colors.green[700],
          ),
        );
        await loadProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Gagal memperbarui username"),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  // ======================
  // UPDATE PASSWORD
  // ======================
  Future<void> changePassword() async {
    if (!canChangePassword) return;

    final oldPass = oldPasswordController.text;
    final newPass = newPasswordController.text;

    final success = await UserService.updatePassword(oldPass, newPass);

    if (mounted) {
      if (success) {
        oldPasswordController.clear();
        newPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Password berhasil diubah"),
            backgroundColor: Colors.green[700],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Gagal mengubah password. Periksa password lama Anda"),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  Future<void> logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2d2d2d),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.red[400]!, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red[400]),
            const SizedBox(width: 12),
            const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          "Apakah Anda yakin ingin keluar?",
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Batal",
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await UserService.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1a1a1a),
              const Color(0xFF2d2d2d),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber[700]!.withOpacity(0.2),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Colors.amber[600]!, Colors.amber[200]!],
                            ).createShader(bounds),
                            child: const Text(
                              "PENGATURAN",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          Text(
                            "Kelola akun Anda",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.settings, color: Colors.amber[600], size: 28),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: loading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Memuat profil...",
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : user == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                                const SizedBox(height: 16),
                                Text(
                                  "User tidak ditemukan",
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ======================
                                // INFO USER
                                // ======================
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey[900]!,
                                        const Color(0xFF2d2d2d),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.amber[700]!.withOpacity(0.3),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber[700]!.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.amber[700]!,
                                              Colors.amber[500]!,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.amber[700]!.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            user!.username[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user!.username,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.purple,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.admin_panel_settings,
                                                    color: Colors.purple,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    user!.role.toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.purple,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // ======================
                                // EDIT USERNAME
                                // ======================
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey[900]!,
                                        const Color(0xFF2d2d2d),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey[800]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.edit, color: Colors.amber[600], size: 20),
                                          const SizedBox(width: 8),
                                          const Text(
                                            "Ubah Username",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[900]!.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.grey[800]!,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: usernameController,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            labelText: "Username (min 3 karakter)",
                                            labelStyle: TextStyle(color: Colors.grey[500]),
                                            prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: canSaveUsername ? saveUsername : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: canSaveUsername
                                                ? Colors.amber[700]
                                                : Colors.grey[800],
                                            disabledBackgroundColor: Colors.grey[800],
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            "Simpan Username",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // ======================
                                // GANTI PASSWORD
                                // ======================
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey[900]!,
                                        const Color(0xFF2d2d2d),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey[800]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.lock, color: Colors.amber[600], size: 20),
                                          const SizedBox(width: 8),
                                          const Text(
                                            "Ganti Password",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[900]!.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.grey[800]!,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: oldPasswordController,
                                          obscureText: obscureOldPassword,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            labelText: "Password Lama",
                                            labelStyle: TextStyle(color: Colors.grey[500]),
                                            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                obscureOldPassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Colors.grey[600],
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  obscureOldPassword = !obscureOldPassword;
                                                });
                                              },
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[900]!.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.grey[800]!,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: newPasswordController,
                                          obscureText: obscureNewPassword,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            labelText: "Password Baru (min 6 karakter)",
                                            labelStyle: TextStyle(color: Colors.grey[500]),
                                            prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                obscureNewPassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Colors.grey[600],
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  obscureNewPassword = !obscureNewPassword;
                                                });
                                              },
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: canChangePassword ? changePassword : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: canChangePassword
                                                ? Colors.blue[700]
                                                : Colors.grey[800],
                                            disabledBackgroundColor: Colors.grey[800],
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            "Ubah Password",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // ======================
                                // LOGOUT
                                // ======================
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red[400]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: logout,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.logout, color: Colors.red[400]),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Logout",
                                            style: TextStyle(
                                              color: Colors.red[400],
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}