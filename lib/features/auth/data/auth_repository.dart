import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../shared/models/user_profile.dart';

/// Authentication state
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserProfile user;
  final String sessionToken;
  const AuthAuthenticated({required this.user, required this.sessionToken});
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final AppError error;
  const AuthError(this.error);
}

/// Auth request/response models
class LoginRequest {
  final String email;
  final String password;
  const LoginRequest({required this.email, required this.password});
}

class RegisterRequest {
  final String displayName;
  final String email;
  final String password;
  const RegisterRequest({
    required this.displayName,
    required this.email,
    required this.password,
  });
}

class AuthResponse {
  final String sessionToken;
  final String userId;
  final UserProfile profile;

  const AuthResponse({
    required this.sessionToken,
    required this.userId,
    required this.profile,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      sessionToken: json['session_token'] as String? ??
          json['token'] as String? ??
          json['access_token'] as String? ??
          '',
      userId: json['user_id'] as String? ?? json['id'] as String? ?? '',
      profile: UserProfile.fromJson(
        (json['profile'] as Map<String, dynamic>?) ?? json,
      ),
    );
  }
}

/// Auth repository — talks to the Neon Functions /auth routes which wrap
/// Neon Managed Better Auth.
class AuthRepository {
  final ApiClient client;
  final FlutterSecureStorage _storage;

  AuthRepository({required this.client, FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<Result<AuthResponse>> login(LoginRequest req) async {
    return client.post(
      '/api/auth/sign-in',
      data: {'email': req.email, 'password': req.password},
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<AuthResponse>> register(RegisterRequest req) async {
    return client.post(
      '/api/auth/sign-up',
      data: {
        'name': req.displayName,
        'email': req.email,
        'password': req.password,
      },
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<bool>> forgotPassword(String email) async {
    return client.post(
      '/api/auth/forgot-password',
      data: {'email': email},
      fromJson: (_) => true,
    );
  }

  Future<Result<UserProfile>> getMe() async {
    return client.get(
      '/api/me',
      fromJson: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<bool>> logout() async {
    return client.post(
      '/api/auth/sign-out',
      data: {},
      fromJson: (_) => true,
    );
  }

  Future<void> saveSession(AuthResponse auth) async {
    await _storage.write(
        key: AppConstants.keySessionToken, value: auth.sessionToken);
    await _storage.write(key: AppConstants.keyUserId, value: auth.userId);
  }

  Future<String?> getSavedToken() async {
    return _storage.read(key: AppConstants.keySessionToken);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: AppConstants.keySessionToken);
    await _storage.delete(key: AppConstants.keyUserId);
    await _storage.delete(key: AppConstants.keyAccessToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
  }
}

/// Demo-mode auth repository — used when DEMO_MODE=true
class DemoAuthRepository extends AuthRepository {
  DemoAuthRepository()
      : super(client: ApiClient());

  @override
  Future<Result<AuthResponse>> login(LoginRequest req) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (req.email.isEmpty || req.password.isEmpty) {
      return const Failure(ValidationError('Email dan kata sandi wajib diisi.'));
    }
    return Success(_demoResponse());
  }

  @override
  Future<Result<AuthResponse>> register(RegisterRequest req) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return Success(_demoResponse(name: req.displayName, email: req.email));
  }

  @override
  Future<Result<bool>> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const Success(true);
  }

  @override
  Future<Result<UserProfile>> getMe() async {
    return Success(_demoProfile());
  }

  @override
  Future<Result<bool>> logout() async {
    return const Success(true);
  }

  AuthResponse _demoResponse({
    String name = 'Demo User',
    String email = 'demo@myjournal.app',
  }) {
    final now = DateTime.now();
    return AuthResponse(
      sessionToken: 'demo-session-token-${now.millisecondsSinceEpoch}',
      userId: 'demo-user-001',
      profile: UserProfile(
        id: 'demo-profile-001',
        authUserId: 'demo-user-001',
        displayName: name,
        email: email,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  UserProfile _demoProfile() {
    final now = DateTime.now();
    return UserProfile(
      id: 'demo-profile-001',
      authUserId: 'demo-user-001',
      displayName: 'Demo User',
      email: 'demo@myjournal.app',
      bio: 'Mode Demo aktif. Data tidak disimpan ke server.',
      createdAt: now,
      updatedAt: now,
    );
  }
}
