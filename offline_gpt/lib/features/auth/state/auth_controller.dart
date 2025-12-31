import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._authRepository) : super(AuthState.unknown());

  final AuthRepository _authRepository;

  Future<void> init() async {
    final tokens = await _authRepository.tokenStorage.readTokens();
    if (tokens == null) {
      state = AuthState.unauthenticated();
      return;
    }

    try {
      final user = await _authRepository.getMe();
      state = AuthState.authenticated(user);
    } catch (_) {
      try {
        await _authRepository.refresh();
        final user = await _authRepository.getMe();
        state = AuthState.authenticated(user);
      } catch (_) {
        await _authRepository.tokenStorage.clear();
        state = AuthState.unauthenticated();
      }
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = AuthState.loading();
    try {
      final user = await _authRepository.login(email: email, password: password);
      state = AuthState.authenticated(user);
    } catch (error) {
      state = AuthState.unauthenticated('Identifiants invalides');
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();
    try {
      final user = await _authRepository.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
    } catch (error) {
      state = AuthState.unauthenticated('Inscription impossible');
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState.unauthenticated();
  }
}
