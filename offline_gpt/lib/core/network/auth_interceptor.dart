import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/data/auth_repository.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStorage,
    required this.authRepository,
    required this.dio,
  });

  final TokenStorage tokenStorage;
  final AuthRepository authRepository;
  final Dio dio;
  Future<void>? _refreshing;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra['skipAuth'] == true) {
      handler.next(options);
      return;
    }

    final accessToken = await tokenStorage.readAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final shouldAttemptRefresh =
        statusCode == 401 && err.requestOptions.extra['retry'] != true;

    if (shouldAttemptRefresh && err.requestOptions.extra['skipAuth'] != true) {
      err.requestOptions.extra['retry'] = true;
      try {
        await _refreshTokens();
        final accessToken = await tokenStorage.readAccessToken();
        if (accessToken != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (_) {
        // Ignore refresh errors and continue.
      }
    }

    handler.next(err);
  }

  Future<void> _refreshTokens() {
    if (_refreshing != null) {
      return _refreshing!;
    }

    _refreshing = authRepository.refresh().whenComplete(() {
      _refreshing = null;
    });

    return _refreshing!;
  }
}
