import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gokgok/core/config/app_env.dart';
import 'package:gokgok/core/theme/theme_provider.dart';
import 'package:gokgok/features/dash_board/pages/dash_board.dart';
import 'package:gokgok/features/loginsignup/pages/login_page.dart';
import 'package:gokgok/features/loginsignup/pages/sign_up_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  _AuthNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

late final GoRouter _route;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();

  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
  );

  _route = GoRouter(
    refreshListenable: _AuthNotifier(),
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
      final location = state.matchedLocation;
      final isAuthRoute = location == '/' || location == '/signup';

      if (!isLoggedIn && !isAuthRoute) return '/';
      if (isLoggedIn && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginPage(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => const DashBoard(),
          ),
          GoRoute(
            path: 'signup',
            builder: (context, state) => const SignUpPage(),
          ),
        ],
      ),
    ],
  );

  runApp(const ProviderScope(child: MyApp()));
}

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
