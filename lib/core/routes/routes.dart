import 'package:go_router/go_router.dart';
import 'package:mina_system/core/layout/app_shell.dart';
import 'package:mina_system/features/auth/presentation/screens/email_entry_screen.dart';
import 'package:mina_system/features/auth/presentation/screens/login_screen.dart';
import 'package:mina_system/features/auth/presentation/screens/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class Routes {
  static const String emailEntry = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';

  static final router = GoRouter(
    initialLocation: emailEntry,
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
      final isGoingToEmailEntry = state.matchedLocation == emailEntry;
      final isGoingToLogin = state.matchedLocation == login;
      final isGoingToRegister = state.matchedLocation == register;
      final isGoingToAuthPage =
          isGoingToEmailEntry || isGoingToLogin || isGoingToRegister;

      if (!isLoggedIn && !isGoingToAuthPage) {
        return emailEntry;
      }

      if (isLoggedIn && isGoingToAuthPage) {
        return dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: emailEntry,
        builder: (context, state) => const EmailEntryScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return LoginScreen(email: email);
        },
      ),
      GoRoute(
        path: register,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return RegisterScreen(email: email);
        },
      ),
      GoRoute(path: dashboard, builder: (context, state) => const AppShell()),
    ],
  );
}
