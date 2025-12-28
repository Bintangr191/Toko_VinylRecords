import 'package:flutter/material.dart';
import 'package:vinylstore/pages/admin/admin_dashboard_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/admin/vinyl_list_page.dart';
import 'pages/user/home_catalog_page.dart';
import 'pages/user/vinyl_detail_page.dart';
import 'pages/user/user_dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      routes: {
        "/login": (_) => const LoginPage(),
        "/register": (_) => const RegisterPage(),
        "/admin": (_) => const AdminDashboardPage(),
        "/user": (_) => const UserDashboardPage(),
      },
    );
  }
}