import 'package:go_router/go_router.dart';
import 'package:mina_system/core/app_mode/app_mode.dart';
import 'package:mina_system/core/app_mode/app_mode_scope.dart';
import 'package:mina_system/core/layout/app_shell.dart';
import 'package:mina_system/features/auth/presentation/screens/email_entry_screen.dart';
import 'package:mina_system/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:mina_system/features/auth/presentation/screens/login_screen.dart';
import 'package:mina_system/features/auth/presentation/screens/register_screen.dart';
import 'package:mina_system/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:mina_system/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class Routes {
  static const String welcome = '/';
  static const String demo = '/demo';

  static const String login = '/login';
  static const String register = '/register';
  static const String emailEntry = '/email-entry';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String dashboard = '/dashboard';

  static final router = GoRouter(
    initialLocation: welcome,
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;

      final isGoingToWelcome = state.matchedLocation == welcome;
      final isGoingToDemo = state.matchedLocation == demo;

      final isGoingToLogin = state.matchedLocation == login;
      final isGoingToRegister = state.matchedLocation == register;
      final isGoingToEmailEntry = state.matchedLocation == emailEntry;
      final isGoingToForgotPassword = state.matchedLocation == forgotPassword;
      final isGoingToResetPassword = state.matchedLocation == resetPassword;

      final isGoingToAuthPage =
          isGoingToLogin ||
          isGoingToEmailEntry ||
          isGoingToForgotPassword ||
          isGoingToResetPassword;

      final isGoingToPublicPage =
          isGoingToWelcome || isGoingToDemo || isGoingToAuthPage;

      // Public registration is intentionally disabled for the Google Play
      // demo-first flow. The screen remains in the project for future
      // invite-based or controlled onboarding.
      if (!isLoggedIn && isGoingToRegister) {
        return welcome;
      }

      // Authenticated users should not access regular auth pages.
      // Reset password is excluded because password recovery creates a temporary session.
      if (isLoggedIn &&
          (isGoingToWelcome || isGoingToRegister || isGoingToAuthPage) &&
          !isGoingToResetPassword) {
        return dashboard;
      }

      // Unauthenticated users must not reach protected live app pages.
      if (!isLoggedIn && !isGoingToPublicPage) {
        return login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: demo,
        builder: (context, state) =>
            const AppModeScope(mode: AppMode.demo, child: AppShell()),
      ),
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
