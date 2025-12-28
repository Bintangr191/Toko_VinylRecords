import 'package:flutter/material.dart';
import 'vinyl_list_page.dart';
import 'user_management_page.dart';
import 'reservation_admin_page.dart';
import 'admin_settings_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _index = 0;

  final pages = const [
    VinylListPage(),
    ReservationAdminPage(),
    UserManagementPage(),
    AdminSettingsPage(),
  ];

  final navItems = [
    {'icon': Icons.album, 'activeIcon': Icons.album, 'label': 'Vinyl'},
    {'icon': Icons.bookmark_border, 'activeIcon': Icons.bookmark, 'label': 'Reservasi'},
    {'icon': Icons.people_outline, 'activeIcon': Icons.people, 'label': 'User'},
    {'icon': Icons.settings_outlined, 'activeIcon': Icons.settings, 'label': 'Setting'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2d2d2d),
              const Color(0xFF1a1a1a),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isSelected = _index == index;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _index = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  Colors.amber[700]!.withOpacity(0.3),
                                  Colors.amber[900]!.withOpacity(0.2),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: Colors.amber[700]!.withOpacity(0.5),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected
                                ? item['activeIcon'] as IconData
                                : item['icon'] as IconData,
                            color: isSelected ? Colors.amber[600] : Colors.grey[600],
                            size: 26,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.amber[600] : Colors.grey[600],
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}