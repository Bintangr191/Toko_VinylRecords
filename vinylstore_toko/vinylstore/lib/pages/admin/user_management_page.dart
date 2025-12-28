import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/admin_user_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  bool loading = true;
  List<UserModel> users = [];
  
  final searchController = TextEditingController();
  String selectedRoleFilter = 'Semua';
  
  final List<String> roleFilterOptions = [
    'Semua',
    'admin',
    'user',
  ];

  @override
  void initState() {
    super.initState();
    load();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() => loading = true);
    users = await AdminUserService.getUsers();
    setState(() => loading = false);
  }

  List<UserModel> _getFilteredUsers() {
    return users.where((user) {
      // Filter by search query (username)
      final searchQuery = searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          user.username.toLowerCase().contains(searchQuery);
      
      // Filter by role
      final matchesRole = selectedRoleFilter == 'Semua' ||
          user.role == selectedRoleFilter;
      
      return matchesSearch && matchesRole;
    }).toList();
  }

  void changeRole(UserModel user) async {
    final newRole = user.role == "admin" ? "user" : "admin";
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2d2d2d),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.amber[700]!, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.swap_horiz, color: Colors.amber[600]),
            const SizedBox(width: 12),
            const Text(
              "Ubah Role",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          "Ubah role ${user.username} menjadi $newRole?",
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
              backgroundColor: Colors.amber[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Ubah",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AdminUserService.updateRole(user.id, newRole);
      load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Role ${user.username} berhasil diubah"),
            backgroundColor: Colors.green[700],
          ),
        );
      }
    }
  }

  void deleteUser(UserModel user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2d2d2d),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.red[400]!, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red[400]),
            const SizedBox(width: 12),
            const Text(
              "Hapus User",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus ${user.username}? Tindakan ini tidak dapat dibatalkan.",
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
              "Hapus",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      await AdminUserService.deleteUser(user.id);
      load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${user.username} berhasil dihapus"),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  String getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'user':
        return 'User';
      default:
        return role;
    }
  }

  Color getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'user':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'user':
        return Icons.person;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();

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
                child: Column(
                  children: [
                    Row(
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
                                  "USER MANAGEMENT",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              Text(
                                "Kelola pengguna sistem",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.people, color: Colors.amber[600], size: 28),
                      ],
                    ),
                    
                    // Search Bar
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900]!.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey[800]!,
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Cari berdasarkan username...",
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.search, color: Colors.amber[600]),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                                  onPressed: () {
                                    searchController.clear();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    
                    // Role Filter Chips
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: roleFilterOptions.map((role) {
                          final isSelected = selectedRoleFilter == role;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                role == 'Semua' ? role : getRoleLabel(role),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  selectedRoleFilter = role;
                                });
                              },
                              backgroundColor: Colors.grey[800],
                              selectedColor: Colors.amber[700],
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[400],
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
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
                              "Memuat pengguna...",
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  searchController.text.isNotEmpty || selectedRoleFilter != 'Semua'
                                      ? Icons.search_off
                                      : Icons.people_outline,
                                  size: 80,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  searchController.text.isNotEmpty || selectedRoleFilter != 'Semua'
                                      ? "Tidak ada hasil"
                                      : "Belum ada pengguna",
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  searchController.text.isNotEmpty || selectedRoleFilter != 'Semua'
                                      ? "Coba kata kunci atau filter lain"
                                      : "Pengguna akan muncul di sini",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: load,
                            color: Colors.amber[600],
                            backgroundColor: const Color(0xFF2d2d2d),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final u = filteredUsers[index];
                                final roleColor = getRoleColor(u.role);
                                final roleIcon = getRoleIcon(u.role);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey[900]!,
                                        const Color(0xFF2d2d2d),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: roleColor.withOpacity(0.3),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: roleColor.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Avatar
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                roleColor.withOpacity(0.8),
                                                roleColor.withOpacity(0.5),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: roleColor.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              u.username[0].toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        
                                        const SizedBox(width: 16),
                                        
                                        // User Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                u.username,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
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
                                                  color: roleColor.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: roleColor,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      roleIcon,
                                                      color: roleColor,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      getRoleLabel(u.role),
                                                      style: TextStyle(
                                                        color: roleColor,
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
                                        
                                        // Action Buttons
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[800]!.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  u.role == "admin"
                                                      ? Icons.person
                                                      : Icons.admin_panel_settings,
                                                  color: Colors.amber[600],
                                                ),
                                                onPressed: () => changeRole(u),
                                                tooltip: "Ubah Role",
                                              ),
                                              Container(
                                                width: 1,
                                                height: 24,
                                                color: Colors.grey[700],
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red[400],
                                                ),
                                                onPressed: () => deleteUser(u),
                                                tooltip: "Hapus User",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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