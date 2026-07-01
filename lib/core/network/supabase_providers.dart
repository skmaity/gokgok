import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Single dependency-injection seam for the Supabase client.
///
/// Data sources and repositories depend on this provider instead of reaching
/// for `Supabase.instance.client` directly. That keeps the data layer
/// injectable/mockable and stops the Supabase singleton from leaking into the
/// rest of the app.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
