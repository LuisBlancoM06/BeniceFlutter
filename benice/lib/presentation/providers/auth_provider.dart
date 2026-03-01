import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import 'repository_providers.dart';

/// Estado de autenticación
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Sentinel value para distinguir "no proporcionado" de "explícitamente null"
const _sentinel = Object();

/// Estado de la autenticación
class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    Object? user = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user == _sentinel ? this.user : user as UserEntity?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

/// Notifier para manejar la autenticación
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(() => _checkAuthStatus());
    return const AuthState();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await ref.read(authRepositoryProvider).getCurrentUser();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) {
        if (user != null) {
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      },
    );
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await ref
        .read(authRepositoryProvider)
        .signIn(email: email, password: password);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return true;
      },
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    String? name,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await ref
        .read(authRepositoryProvider)
        .signUp(email: email, password: password, name: name);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return true;
      },
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  // Aliases para compatibilidad
  Future<bool> signIn({required String email, required String password}) =>
      login(email: email, password: password);

  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) => register(email: email, password: password, name: name);

  Future<bool> resetPassword({required String email}) async {
    final result = await ref
        .read(authRepositoryProvider)
        .resetPassword(email: email);

    return result.fold((failure) => false, (_) => true);
  }

  /// Suscribe a newsletter y devuelve el código promo generado (o null si falla)
  Future<String?> subscribeToNewsletter({required String email}) async {
    final result = await ref
        .read(authRepositoryProvider)
        .subscribeToNewsletter(email: email);

    return result.fold((failure) => null, (promoCode) => promoCode);
  }

  /// Refresh the current user data from the backend
  Future<void> refreshUser() async {
    final result = await ref.read(authRepositoryProvider).getCurrentUser();
    result.fold(
      (_) {}, // Keep current state on failure
      (user) {
        if (user != null) {
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        }
      },
    );
  }

  void clearError() {
    if (state.errorMessage == null) return; // No-op si ya no hay error
    state = state.copyWith(
      status: state.status == AuthStatus.error
          ? AuthStatus.unauthenticated
          : null,
      errorMessage: null,
    );
  }
}

/// Provider del estado de autenticación
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Provider para saber si el usuario está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Provider del usuario actual
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).user;
});
