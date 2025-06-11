import 'package:birth_certify/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:birth_certify/features/auth/data/repository/auth_repository_impl.dart';
import 'package:birth_certify/features/auth/domain/models/user_model.dart';
import 'package:birth_certify/features/auth/domain/repository/auth_repository.dart';
import 'package:birth_certify/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(AuthFirebaseDataSource());
});

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});


final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  return await ref.watch(authRepositoryProvider).fetchCurrentUserDetails();
});
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(AuthState.initial());

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(error: 'Email and password are required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _repository.login(email, password);
      if (success) {
        state = state.copyWith(isLoading: false, isLoggedIn: true);
      } else {
        state = state.copyWith(isLoading: false, error: 'Invalid credentials');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _repository.logout();
      if (success) {
        state = state.copyWith(isLoading: false, isLoggedIn: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Logout failed');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }
}
