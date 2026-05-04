abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthRegisterSuccess extends AuthState {
  AuthRegisterSuccess({
    required this.requiresEmailConfirmation,
  });

  final bool requiresEmailConfirmation;
}

class AuthFailure extends AuthState {
  AuthFailure(this.message);

  final String message;
}