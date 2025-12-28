// 

// gg

import 'package:flutter/material.dart';
import 'home_catalog_page.dart';
import 'wishlist_page.dart';
import 'user_settings_page.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _index = 0;

  final pages = const [
    HomeCatalogPage(),
    WishlistPage(),
    UserSettingsPage(),
  ];

  final navItems = [
    {'icon': Icons.dashboard, 'activeIcon': Icons.dashboard, 'label': 'Vinyl'},
    {'icon': Icons.favorite_border, 'activeIcon': Icons.favorite, 'label': 'whislist'},
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