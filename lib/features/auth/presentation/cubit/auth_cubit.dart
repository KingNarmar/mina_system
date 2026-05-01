import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> login({
    required String emailOrUsername,
    required String password,
  }) async {
    emit(AuthLoading());

    await Future.delayed(const Duration(seconds: 1));

    if (emailOrUsername == 'admin' && password == '123456') {
      emit(AuthSuccess());
    } else {
      emit(AuthFailure('Invalid email or password'));
    }
  }
}
