import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_constants.dart';
import '../errors/app_error.dart';

/// HTTP client configured for My Journal API (Neon Functions/Hono backend).
/// Automatically attaches auth token and handles common error cases.
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(_AuthInterceptor(_storage));
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      error: true,
    ));
  }

  Dio get dio => _dio;

  // ─── Convenience wrappers ──────────────────────────────────────────────────

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      return Success(fromJson(response.data));
    } on DioException catch (e) {
      return Failure(_mapDioError(e));
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<Result<T>> post<T>(
    String path, {
    required Map<String, dynamic> data,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return Success(fromJson(response.data));
    } on DioException catch (e) {
      return Failure(_mapDioError(e));
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<Result<T>> patch<T>(
    String path, {
    required Map<String, dynamic> data,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.patch(path, data: data);
      return Success(fromJson(response.data));
    } on DioException catch (e) {
      return Failure(_mapDioError(e));
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  Future<Result<bool>> delete(String path) async {
    try {
      await _dio.delete(path);
      return const Success(true);
    } on DioException catch (e) {
      return Failure(_mapDioError(e));
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  AppError _mapDioError(DioException e) {
    if (e.error is SocketException) {
      return const NetworkError();
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkError('Koneksi habis waktu. Coba lagi.');
      case DioExceptionType.connectionError:
        return const NetworkError();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return const UnauthorizedError();
        if (statusCode == 404) return const NotFoundError();
        final message = _extractErrorMessage(e.response?.data) ??
            'Kesalahan server ($statusCode)';
        return ServerError(message, statusCode);
      default:
        return UnknownError(e.message ?? 'Kesalahan tidak diketahui');
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['msg'] as String?;
    }
    return null;
  }
}

/// Interceptor that attaches Bearer token to every request.
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  _AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: AppConstants.keySessionToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
