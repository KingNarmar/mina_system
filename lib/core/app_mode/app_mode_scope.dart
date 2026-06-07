import 'package:flutter/widgets.dart';
import 'package:mina_system/core/app_mode/app_mode.dart';

class AppModeScope extends InheritedWidget {
  const AppModeScope({super.key, required this.mode, required super.child});

  final AppMode mode;

  static AppMode of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppModeScope>();

    if (scope == null) {
      throw FlutterError(
        'AppModeScope.of() called with a context that does not contain an AppModeScope.\n'
        'Make sure MinaSystem wraps the app with AppModeScope before reading AppMode.',
      );
    }

    return scope.mode;
  }

  static AppMode? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppModeScope>()?.mode;
  }

  @override
  bool updateShouldNotify(AppModeScope oldWidget) {
    return mode != oldWidget.mode;
  }
}
