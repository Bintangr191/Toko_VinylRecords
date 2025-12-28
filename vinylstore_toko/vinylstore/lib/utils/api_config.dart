import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String baseUrl() {
    if (kIsWeb) return "http://localhost:3000";
    if (Platform.isAndroid) return "http://10.0.2.2:3000";
    return "http://localhost:3000";
  }

  static String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    if (url.startsWith("http")) return url;
    return "${baseUrl()}$url";
  }

  static String resolveUrl(String? path){
    if(path==null || path.isEmpty) return "";
    if(path.startsWith("http")) return path;
    return "${baseUrl()}$path";
  }
}