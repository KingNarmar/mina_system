import 'package:go_router/go_router.dart';
import 'package:mina_system/core/layout/app_shell.dart';
import 'package:mina_system/features/auth/presentation/screens/email_entry_screen.dart';
import 'package:mina_system/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:mina_system/features/auth/presentation/screens/login_screen.dart';
import 'package:mina_system/features/auth/presentation/screens/register_screen.dart';
import 'package:mina_system/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String emailEntry = '/email-entry';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String dashboard = '/dashboard';

  static final router = GoRouter(
    initialLocation: login,
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;

      final isGoingToLogin = state.matchedLocation == login;
      final isGoingToRegister = state.matchedLocation == register;
      final isGoingToEmailEntry = state.matchedLocation == emailEntry;
      final isGoingToForgotPassword = state.matchedLocation == forgotPassword;
      final isGoingToResetPassword = state.matchedLocation == resetPassword;

      final isGoingToAuthPage =
          isGoingToLogin ||
          isGoingToRegister ||
          isGoingToEmailEntry ||
          isGoingToForgotPassword ||
          isGoingToResetPassword;

      // Authenticated users should not access regular auth pages.
      // Reset password is excluded because password recovery creates a temporary session.
      if (isLoggedIn && isGoingToAuthPage && !isGoingToResetPassword) {
        return dashboard;
      }

      // Unauthenticated users must not reach protected app pages.
      if (!isLoggedIn && !isGoingToAuthPage) {
        return login;
      }

      return null;
    },
    routes: [
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // Legacy route kept temporarily during auth flow redesign.
      GoRoute(
        path: emailEntry,
        builder: (context, state) => const EmailEntryScreen(),
      ),

      GoRoute(path: dashboard, builder: (context, state) => const AppShell()),
    ],
  );
}
