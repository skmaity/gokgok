import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gokgok/core/network/supabase_providers.dart';
import 'package:gokgok/core/routing/app_routes.dart';
import 'package:gokgok/features/auth/presentation/screens/login_page.dart';
import 'package:gokgok/features/auth/presentation/screens/sign_up_page.dart';
import 'package:gokgok/features/chat/presentation/screens/chat_members_page.dart';
import 'package:gokgok/features/chat/presentation/screens/group_chat_page.dart';
import 'package:gokgok/features/dashboard/presentation/screens/dash_board.dart';
import 'package:gokgok/features/groups/domain/entities/group_model.dart';
import 'package:gokgok/features/profile/presentation/screens/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Re-runs the router's redirect whenever the Supabase auth state changes
/// (login / logout), so the user is moved between the auth and app shells.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(SupabaseClient client) {
    _sub = client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Exposes the application [GoRouter], wired to the injected Supabase client
/// for auth-based redirects. Built once and disposed with the provider scope.
final routerProvider = Provider<GoRouter>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final refresh = _AuthRefreshListenable(client);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) {
      final isLoggedIn = client.auth.currentUser != null;
      final location = state.matchedLocation;
      final isAuthRoute =
          location == AppRoutes.login || location == AppRoutes.signup;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.dashboard;
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashBoard(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) =>
            GroupChatPage(group: state.extra as GroupModel),
      ),
      GoRoute(
        path: AppRoutes.chatMembers,
        builder: (context, state) =>
            ChatMembersPage(group: state.extra as GroupModel),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
