import 'package:go_router/go_router.dart';
import 'package:mina_system/features/auth/presentation/screens/login_screen.dart';

class Routes {
  static const String login = '/';

  static var router = GoRouter(
    routes: [
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
    ],
  );
}
