import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gokgok/core/config/app_env.dart';
import 'package:gokgok/core/theme/theme_provider.dart';
import 'package:gokgok/features/dash_board/pages/dash_board.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();

  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
  );
  runApp(const ProviderScope(child: MyApp()));
}

final GoRouter _route = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    if (isLoggedIn && state.matchedLocation == '/') return '/dashboard';
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const DashBoard(),
      routes: [
        GoRoute(
          path: 'dashboard',
          builder: (context, state) => const DashBoard(),
        ),
      ],
    ),
  ],
);

// shubha kumar
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, child) {
        return MaterialApp.router(
          routerConfig: _route,
          debugShowCheckedModeBanner: false,
          theme: theme,
        );
      },
    );
  }
}
