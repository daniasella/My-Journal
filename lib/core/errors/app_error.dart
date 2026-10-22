/// App-level error types for consistent error handling
sealed class AppError {
  final String message;
  const AppError(this.message);
}

class NetworkError extends AppError {
  const NetworkError([super.message = 'Terjadi kesalahan koneksi. Periksa internet kamu.']);
}

class ServerError extends AppError {
  final int? statusCode;
  const ServerError([super.message = 'Terjadi kesalahan server.', this.statusCode]);
}

class UnauthorizedError extends AppError {
  const UnauthorizedError(
      [super.message = 'Sesi kamu telah berakhir. Silakan masuk kembali.']);
}

class NotFoundError extends AppError {
  const NotFoundError([super.message = 'Data tidak ditemukan.']);
}

class ValidationError extends AppError {
  final Map<String, String> fields;
  const ValidationError(super.message, {this.fields = const {}});
}

class ConfigurationError extends AppError {
  const ConfigurationError(
      [super.message = 'Backend belum dikonfigurasi. Mode Demo aktif.']);
}

class StorageError extends AppError {
  const StorageError([super.message = 'Gagal mengakses penyimpanan.']);
}

class CacheError extends AppError {
  const CacheError([super.message = 'Gagal mengakses cache lokal.']);
}

class PermissionError extends AppError {
  const PermissionError([super.message = 'Izin yang diperlukan belum diberikan.']);
}

class UnknownError extends AppError {
  const UnknownError([super.message = 'Terjadi kesalahan yang tidak diketahui.']);
}

/// Result type for safe error handling
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}
