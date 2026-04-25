import 'dart:convert';

import 'package:flutter/services.dart';

class AppEnv {
  AppEnv._();

  static late final String supabaseUrl;
  static late final String supabaseAnonKey;

  static Future<void> load() async {
    final rawJson = await rootBundle.loadString('env.json');
    final json = jsonDecode(rawJson) as Map<String, dynamic>;

    supabaseUrl = (json['SUPABASE_URL'] as String? ?? '').trim();
    supabaseAnonKey = (json['SUPABASE_ANON_KEY'] as String? ?? '').trim();

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'Missing SUPABASE_URL or SUPABASE_ANON_KEY in env.json.',
      );
    }
  }
}
