import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(plainDioProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

class AuthRepository {
  AuthRepository({required this.dio, required this.tokenStorage});

  final Dio dio;
  final TokenStorage tokenStorage;

  Future<UserProfile> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/auth/register',
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
      },
    );

    final tokens = TokenPair(
      accessToken: response.data['accessToken'] as String,
      refreshToken: response.data['refreshToken'] as String,
    );
    await tokenStorage.saveTokens(tokens);

    return UserProfile.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final tokens = TokenPair(
      accessToken: response.data['accessToken'] as String,
      refreshToken: response.data['refreshToken'] as String,
    );
    await tokenStorage.saveTokens(tokens);

    return UserProfile.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<UserProfile> getMe() async {
    final accessToken = await tokenStorage.readAccessToken();
    if (accessToken == null) {
      throw Exception('Missing access token');
    }

    final response = await dio.get(
      '/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> refresh() async {
    final refreshToken = await tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      throw Exception('Missing refresh token');
    }

    final response = await dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    final tokens = TokenPair(
      accessToken: response.data['accessToken'] as String,
      refreshToken: response.data['refreshToken'] as String,
    );
    await tokenStorage.saveTokens(tokens);
  }

  Future<void> logout() async {
    final refreshToken = await tokenStorage.readRefreshToken();
    if (refreshToken != null) {
      await dio.post(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    }
    await tokenStorage.clear();
  }
}
