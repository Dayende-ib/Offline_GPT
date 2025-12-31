import '../domain/user.dart';

enum AuthStatus { unknown, unauthenticated, authenticated, loading }

class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  factory AuthState.unknown() => const AuthState(status: AuthStatus.unknown);

  factory AuthState.unauthenticated([String? errorMessage]) => AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: errorMessage,
      );

  factory AuthState.authenticated(UserProfile user) =>
      AuthState(status: AuthStatus.authenticated, user: user);

  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
}
