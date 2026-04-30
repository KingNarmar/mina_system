import 'package:go_router/go_router.dart';
import 'package:mina_system/features/auth/presentation/screens/login_screen.dart';
import 'package:mina_system/features/dashboard/presentation/screens/dashboard_screen.dart';

abstract class Routes {
  static const String login = '/';
  static const String dashboard = '/dashboard';

  static final router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
}
