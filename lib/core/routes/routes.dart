import 'package:go_router/go_router.dart';
import 'package:mina_system/core/layout/app_shell.dart';
import 'package:mina_system/features/auth/presentation/screens/login_screen.dart';
import 'package:mina_system/features/auth/presentation/screens/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class Routes {
  static const String login = '/';
  static const String register = '/register';
  static const String dashboard = '/dashboard';

  static final router = GoRouter(
    initialLocation: login,
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
      final isGoingToLogin = state.matchedLocation == login;
      final isGoingToRegister = state.matchedLocation == register;
      final isGoingToAuthPage = isGoingToLogin || isGoingToRegister;

      if (!isLoggedIn && !isGoingToAuthPage) {
        return login;
      }

      if (isLoggedIn && isGoingToAuthPage) {
        return dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: dashboard, builder: (context, state) => const AppShell()),
    ],
  );
}
