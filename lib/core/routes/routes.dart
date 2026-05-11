import 'package:go_router/go_router.dart';
import 'package:mina_system/core/layout/app_shell.dart';
import 'package:mina_system/core/validators/app_validators.dart';
import 'package:mina_system/features/auth/presentation/screens/email_entry_screen.dart';
import 'package:mina_system/features/auth/presentation/screens/login_screen.dart';
import 'package:mina_system/features/auth/presentation/screens/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class Routes {
  static const String emailEntry = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';

  static bool _hasValidEmailExtra(Object? extra) {
    if (extra is! String) return false;
    return AppValidators.validateEmail(extra.trim()) == null;
  }

  static final router = GoRouter(
    initialLocation: emailEntry,
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
      final isGoingToEmailEntry = state.matchedLocation == emailEntry;
      final isGoingToLogin = state.matchedLocation == login;
      final isGoingToRegister = state.matchedLocation == register;
      final isGoingToAuthPage =
          isGoingToEmailEntry || isGoingToLogin || isGoingToRegister;

      // Authenticated users cannot access any auth page.
      if (isLoggedIn && isGoingToAuthPage) {
        return dashboard;
      }

      // Unauthenticated users must not reach protected app pages.
      if (!isLoggedIn && !isGoingToAuthPage) {
        return emailEntry;
      }

      // Guard /login and /register: require a valid email passed as extra.
      // Without it, the form would show an empty locked email field.
      if (!isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        if (!_hasValidEmailExtra(state.extra)) {
          return emailEntry;
        }
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
          final email = state.extra as String;
          return LoginScreen(email: email);
        },
      ),
      GoRoute(
        path: register,
        builder: (context, state) {
          final email = state.extra as String;
          return RegisterScreen(email: email);
        },
      ),
      GoRoute(path: dashboard, builder: (context, state) => const AppShell()),
    ],
  );
}
