import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../shared/models/user_profile.dart';
import '../data/auth_repository.dart';

// ── Providers ────────────────────────────────────────────────────────────────

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage: storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConstants.isDemoMode) return DemoAuthRepository();
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(client: client, storage: storage);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});

/// Convenience provider — the authenticated user profile (null if not logged in)
final currentUserProvider = Provider<UserProfile?>((ref) {
  final state = ref.watch(authControllerProvider);
  return switch (state) {
    AuthAuthenticated a => a.user,
    _ => null,
  };
});

// ── Controller ───────────────────────────────────────────────────────────────

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthController(this._repo) : super(const AuthInitial()) {
    _tryRestoreSession();
  }

  Future<void> _tryRestoreSession() async {
    state = const AuthLoading();
    final token = await _repo.getSavedToken();
    if (token == null || token.isEmpty) {
      state = const AuthUnauthenticated();
      return;
    }
    final result = await _repo.getMe();
    switch (result) {
      case Success<UserProfile>(:final data):
        state = AuthAuthenticated(user: data, sessionToken: token);
      case Failure<UserProfile>():
        await _repo.clearSession();
        state = const AuthUnauthenticated();
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AuthLoading();
    final result = await _repo.login(LoginRequest(email: email, password: password));
    switch (result) {
      case Success<AuthResponse>(:final data):
        await _repo.saveSession(data);
        state = AuthAuthenticated(user: data.profile, sessionToken: data.sessionToken);
        return true;
      case Failure<AuthResponse>(:final error):
        state = AuthError(error);
        return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = const AuthLoading();
    final result = await _repo.register(
        RegisterRequest(displayName: name, email: email, password: password));
    switch (result) {
      case Success<AuthResponse>(:final data):
        await _repo.saveSession(data);
        state = AuthAuthenticated(user: data.profile, sessionToken: data.sessionToken);
        return true;
      case Failure<AuthResponse>(:final error):
        state = AuthError(error);
        return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = const AuthLoading();
    final result = await _repo.forgotPassword(email);
    switch (result) {
      case Success<bool>():
        state = const AuthUnauthenticated();
        return true;
      case Failure<bool>(:final error):
        state = AuthError(error);
        return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    await _repo.clearSession();
    state = const AuthUnauthenticated();
  }

  void updateProfile(UserProfile updated) {
    final current = state;
    if (current is AuthAuthenticated) {
      state = AuthAuthenticated(user: updated, sessionToken: current.sessionToken);
    }
  }

  void clearError() {
    final current = state;
    if (current is AuthError) {
      state = const AuthUnauthenticated();
    }
  }
}
