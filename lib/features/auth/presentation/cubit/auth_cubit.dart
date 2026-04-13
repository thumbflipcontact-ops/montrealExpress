import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import '../../data/models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    try {
      final result = await _authRepository.checkAuthStatus();
      if (result['isAuthenticated'] == true) {
        final isGuest = result['isGuest'] ?? false;
        if (!isGuest) {
          // Fetch real user profile
          try {
            final user = await _authRepository.getProfile();
            emit(AuthAuthenticated(isGuest: false, user: user));
          } catch (_) {
            // Profile fetch failed but still authenticated
            emit(const AuthAuthenticated(isGuest: false));
          }
        } else {
          emit(const AuthAuthenticated(isGuest: true));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.loginWithEmail(email, password);
      // Fetch user profile after login
      try {
        final user = await _authRepository.getProfile();
        emit(AuthAuthenticated(isGuest: false, user: user));
      } catch (_) {
        emit(const AuthAuthenticated(isGuest: false));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> signupWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    emit(AuthLoading());
    try {
      await _authRepository.signupWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      try {
        final user = await _authRepository.getProfile();
        emit(AuthAuthenticated(isGuest: false, user: user));
      } catch (_) {
        emit(const AuthAuthenticated(isGuest: false));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> loginWithPhone(String phoneNumber) async {
    emit(AuthLoading());
    try {
      await _authRepository.loginWithPhone(phoneNumber);
      emit(AuthCodeSent(phoneNumber));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> verifyOtp(String otpCode) async {
    emit(AuthLoading());
    try {
      await _authRepository.verifyOtp(
        otpCode: otpCode,
        phoneNumber: state is AuthCodeSent
            ? (state as AuthCodeSent).phoneNumber
            : '',
      );
      try {
        final user = await _authRepository.getProfile();
        emit(AuthAuthenticated(isGuest: false, user: user));
      } catch (_) {
        emit(const AuthAuthenticated(isGuest: false));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> loginAsGuest() async {
    emit(AuthLoading());
    try {
      await _authRepository.loginAsGuest();
      emit(const AuthAuthenticated(isGuest: true));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> refreshProfile() async {
    try {
      final user = await _authRepository.getProfile();
      if (state is AuthAuthenticated) {
        final current = state as AuthAuthenticated;
        emit(AuthAuthenticated(isGuest: current.isGuest, user: user));
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  /// Helper: get the current authenticated user or null
  UserModel? get currentUser {
    final s = state;
    if (s is AuthAuthenticated) return s.user;
    return null;
  }
}
