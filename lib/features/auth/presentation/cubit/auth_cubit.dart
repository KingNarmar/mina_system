import 'package:flutter_bloc/flutter_bloc.dart';
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
    } on AuthException catch (error) {
      emit(AuthFailure(error.message));
    } catch (_) {
      emit(AuthFailure('Something went wrong. Please try again.'));
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
      data: {
        'full_name': fullName.trim(),
      },
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
  } on AuthException catch (error) {
    emit(AuthFailure(error.message));
  } catch (_) {
    emit(AuthFailure('Something went wrong. Please try again.'));
  }
}
}
