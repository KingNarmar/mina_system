import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/utils/app_error_message.dart';
import 'package:mina_system/features/auth/presentation/cubit/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client,
      super(AuthInitial());

  final SupabaseClient _supabase;

  Future<void> login({
    required String emailOrUsername,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: emailOrUsername.trim(),
        password: password.trim(),
      );

      if (response.session == null || response.user == null) {
        emit(AuthFailure('Login failed. Please try again.'));
        return;
      }

      emit(AuthSuccess());
    } catch (error) {
      emit(
        AuthFailure(
          AppErrorMessage.fromError(
            error,
            fallback: 'Login failed. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {'full_name': fullName.trim()},
      );

      if (response.user == null) {
        emit(AuthFailure('Registration failed. Please try again.'));
        return;
      }

      emit(
        AuthRegisterSuccess(
          requiresEmailConfirmation: response.session == null,
        ),
      );
    } catch (error) {
      emit(
        AuthFailure(
          AppErrorMessage.fromError(
            error,
            fallback: 'Registration failed. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    final normalizedEmail = email.trim();

    emit(AuthLoading());

    try {
      await _supabase.auth.resetPasswordForEmail(normalizedEmail);

      emit(AuthPasswordResetEmailSent(email: normalizedEmail));
    } catch (error) {
      emit(
        AuthFailure(
          AppErrorMessage.fromError(
            error,
            fallback: 'Failed to send password reset email. Please try again.',
          ),
        ),
      );
    }
  }
}
