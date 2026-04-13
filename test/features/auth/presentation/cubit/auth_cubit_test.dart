import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:abdoul_express/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:abdoul_express/features/auth/presentation/cubit/auth_state.dart';
import 'package:abdoul_express/features/auth/data/auth_repository.dart';

/// Mock AuthRepository for testing
class MockAuthRepository extends Mock implements AuthRepository {}

/// Tests for AuthCubit
///
/// This test suite covers:
/// - Email/Password login states
/// - Phone/OTP login states
/// - Signup states
/// - Session management
/// - Error scenarios
/// - Edge cases
///
/// Total: 30 tests
void main() {
  late AuthCubit authCubit;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    authCubit = AuthCubit(mockRepository);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit -', () {
    group('Initial State |', () {
      test('initial state should be AuthInitial', () {
        // Assert
        expect(authCubit.state, isA<AuthInitial>());
      });
    });

    group('Email Login |', () {
      const email = 'user@abdoulexpress.com';
      const password = 'password123';

      blocTest<AuthCubit, AuthState>(
        'SUCCESS: emits [Loading, Authenticated] when login succeeds',
        build: () {
          when(() => mockRepository.loginWithEmail(email, password))
              .thenAnswer((_) async => 'mock_token_123');
          return authCubit;
        },
        act: (cubit) => cubit.loginWithEmail(email, password),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
        verify: (_) {
          verify(() => mockRepository.loginWithEmail(email, password))
              .called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'FAILURE: emits [Loading, Error] when login fails with invalid credentials',
        build: () {
          when(() => mockRepository.loginWithEmail(email, password))
              .thenThrow(Exception('Email ou mot de passe incorrect'));
          return authCubit;
        },
        act: (cubit) => cubit.loginWithEmail(email, password),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            contains('Email ou mot de passe incorrect'),
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'FAILURE: emits [Loading, Error] when login fails with network error',
        build: () {
          when(() => mockRepository.loginWithEmail(email, password))
              .thenThrow(Exception('Network error'));
          return authCubit;
        },
        act: (cubit) => cubit.loginWithEmail(email, password),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            contains('Network error'),
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'VALIDATION: emits [Loading, Error] for empty email',
        build: () {
          when(() => mockRepository.loginWithEmail('', password))
              .thenThrow(Exception('Email cannot be empty'));
          return authCubit;
        },
        act: (cubit) => cubit.loginWithEmail('', password),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'VALIDATION: emits [Loading, Error] for empty password',
        build: () {
          when(() => mockRepository.loginWithEmail(email, ''))
              .thenThrow(Exception('Password cannot be empty'));
          return authCubit;
        },
        act: (cubit) => cubit.loginWithEmail(email, ''),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'IDEMPOTENT: can call loginWithEmail multiple times',
        build: () {
          when(() => mockRepository.loginWithEmail(email, password))
              .thenAnswer((_) async => 'mock_token_123');
          return authCubit;
        },
        act: (cubit) async {
          await cubit.loginWithEmail(email, password);
          await cubit.loginWithEmail(email, password);
        },
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
      );
    });

    group('Phone Login |', () {
      const phone = '+22790123456';

      blocTest<AuthCubit, AuthState>(
        'SUCCESS: emits [Loading, CodeSent] when phone login succeeds',
        build: () {
          when(() => mockRepository.loginWithPhone(phone))
              .thenAnswer((_) async {});
          return authCubit;
        },
        act: (cubit) => cubit.loginWithPhone(phone),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthCodeSent>().having(
            (state) => state.phoneNumber,
            'phone number',
            equals(phone),
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.loginWithPhone(phone)).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'FAILURE: emits [Loading, Error] when phone login fails',
        build: () {
          when(() => mockRepository.loginWithPhone(phone))
              .thenThrow(Exception('Invalid phone number'));
          return authCubit;
        },
        act: (cubit) => cubit.loginWithPhone(phone),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            contains('Invalid phone number'),
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'VALIDATION: emits [Loading, Error] for empty phone',
        build: () {
          when(() => mockRepository.loginWithPhone(''))
              .thenThrow(Exception('Phone number cannot be empty'));
          return authCubit;
        },
        act: (cubit) => cubit.loginWithPhone(''),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'VALIDATION: emits [Loading, Error] for invalid phone format',
        build: () {
          when(() => mockRepository.loginWithPhone('123'))
              .thenThrow(Exception('Invalid phone format'));
          return authCubit;
        },
        act: (cubit) => cubit.loginWithPhone('123'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });

    group('OTP Verification |', () {
      const otp = '123456';

      blocTest<AuthCubit, AuthState>(
        'SUCCESS: emits [Loading, Authenticated] when OTP is valid',
        build: () {
          when(() => mockRepository.verifyOtp(otp))
              .thenAnswer((_) async => 'mock_token_123');
          return authCubit;
        },
        act: (cubit) => cubit.verifyOtp(otp),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
        verify: (_) {
          verify(() => mockRepository.verifyOtp(otp)).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'FAILURE: emits [Loading, Error] when OTP is invalid',
        build: () {
          when(() => mockRepository.verifyOtp(otp))
              .thenThrow(Exception('Code OTP incorrect'));
          return authCubit;
        },
        act: (cubit) => cubit.verifyOtp(otp),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            contains('Code OTP incorrect'),
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'VALIDATION: emits [Loading, Error] for empty OTP',
        build: () {
          when(() => mockRepository.verifyOtp(''))
              .thenThrow(Exception('OTP cannot be empty'));
          return authCubit;
        },
        act: (cubit) => cubit.verifyOtp(''),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'FAILURE: emits [Loading, Error] when OTP expired',
        build: () {
          when(() => mockRepository.verifyOtp(otp))
              .thenThrow(Exception('Code OTP expiré'));
          return authCubit;
        },
        act: (cubit) => cubit.verifyOtp(otp),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            contains('Code OTP expiré'),
          ),
        ],
      );
    });

    group('Signup |', () {
      const email = 'newuser@example.com';
      const password = 'password123';

      blocTest<AuthCubit, AuthState>(
        'SUCCESS: emits [Loading, Authenticated] when signup succeeds',
        build: () {
          when(() => mockRepository.signupWithEmail(email, password))
              .thenAnswer((_) async => 'mock_token_123');
          return authCubit;
        },
        act: (cubit) => cubit.signupWithEmail(email, password),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
        verify: (_) {
          verify(() => mockRepository.signupWithEmail(email, password))
              .called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'FAILURE: emits [Loading, Error] when email already exists',
        build: () {
          when(() => mockRepository.signupWithEmail(email, password))
              .thenThrow(Exception('Cet email est déjà utilisé'));
          return authCubit;
        },
        act: (cubit) => cubit.signupWithEmail(email, password),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            contains('Cet email est déjà utilisé'),
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'VALIDATION: emits [Loading, Error] for invalid email format',
        build: () {
          when(() => mockRepository.signupWithEmail('invalid-email', password))
              .thenThrow(Exception('Invalid email format'));
          return authCubit;
        },
        act: (cubit) => cubit.signupWithEmail('invalid-email', password),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'VALIDATION: emits [Loading, Error] for weak password',
        build: () {
          when(() => mockRepository.signupWithEmail(email, '123'))
              .thenThrow(Exception('Password too weak'));
          return authCubit;
        },
        act: (cubit) => cubit.signupWithEmail(email, '123'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'FAILURE: emits [Loading, Error] when network fails during signup',
        build: () {
          when(() => mockRepository.signupWithEmail(email, password))
              .thenThrow(Exception('Network error'));
          return authCubit;
        },
        act: (cubit) => cubit.signupWithEmail(email, password),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            contains('Network error'),
          ),
        ],
      );
    });

    group('Session Management |', () {
      blocTest<AuthCubit, AuthState>(
        'SUCCESS: emits [Authenticated] when user is logged in',
        build: () {
          when(() => mockRepository.checkAuthStatus())
              .thenAnswer((_) async => {'isAuthenticated': true, 'isGuest': false});
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          isA<AuthAuthenticated>(),
        ],
        verify: (_) {
          verify(() => mockRepository.checkAuthStatus()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'SUCCESS: emits [Unauthenticated] when user is not logged in',
        build: () {
          when(() => mockRepository.checkAuthStatus())
              .thenAnswer((_) async => {'isAuthenticated': false, 'isGuest': false});
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          isA<AuthUnauthenticated>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'RESILIENT: emits [Unauthenticated] when checkAuthStatus throws error',
        build: () {
          when(() => mockRepository.checkAuthStatus())
              .thenThrow(Exception('Storage error'));
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          isA<AuthUnauthenticated>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'IDEMPOTENT: can call checkAuthStatus multiple times',
        build: () {
          when(() => mockRepository.checkAuthStatus())
              .thenAnswer((_) async => {'isAuthenticated': true, 'isGuest': false});
          return authCubit;
        },
        act: (cubit) async {
          await cubit.checkAuthStatus();
          await cubit.checkAuthStatus();
          await cubit.checkAuthStatus();
        },
        expect: () => [
          isA<AuthAuthenticated>(),
          // Subsequent calls don't emit because state is already Authenticated
        ],
        verify: (_) {
          // Verify repository was called 3 times
          verify(() => mockRepository.checkAuthStatus()).called(3);
        },
      );
    });

    group('Logout |', () {
      blocTest<AuthCubit, AuthState>(
        'SUCCESS: emits [Unauthenticated] when logout is called',
        build: () {
          when(() => mockRepository.logout()).thenAnswer((_) async {});
          return authCubit;
        },
        act: (cubit) => cubit.logout(),
        expect: () => [
          isA<AuthUnauthenticated>(),
        ],
        verify: (_) {
          verify(() => mockRepository.logout()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'IDEMPOTENT: logout works even when already unauthenticated',
        build: () {
          when(() => mockRepository.logout()).thenAnswer((_) async {});
          return authCubit;
        },
        seed: () => AuthUnauthenticated(),
        act: (cubit) => cubit.logout(),
        expect: () => [],
        verify: (_) {
          // Verify repository logout was still called
          verify(() => mockRepository.logout()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'IDEMPOTENT: can call logout multiple times',
        build: () {
          when(() => mockRepository.logout()).thenAnswer((_) async {});
          return authCubit;
        },
        seed: () => AuthAuthenticated(),
        act: (cubit) async {
          await cubit.logout();
          await cubit.logout();
        },
        expect: () => [
          isA<AuthUnauthenticated>(),
          // Second logout doesn't emit because state is already Unauthenticated
        ],
        verify: (_) {
          // Verify repository logout was called twice
          verify(() => mockRepository.logout()).called(2);
        },
      );
    });

    group('Edge Cases & State Transitions |', () {
      blocTest<AuthCubit, AuthState>(
        'FLOW: Complete phone login flow (Phone → CodeSent → OTP → Authenticated)',
        build: () {
          when(() => mockRepository.loginWithPhone('+22790123456'))
              .thenAnswer((_) async {});
          when(() => mockRepository.verifyOtp('123456'))
              .thenAnswer((_) async => 'mock_token_123');
          return authCubit;
        },
        act: (cubit) async {
          await cubit.loginWithPhone('+22790123456');
          await cubit.verifyOtp('123456');
        },
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthCodeSent>(),
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'FLOW: Login → Logout → Login again',
        build: () {
          when(() => mockRepository.loginWithEmail(
                  'user@abdoulexpress.com', 'password123'))
              .thenAnswer((_) async => 'mock_token_123');
          when(() => mockRepository.logout()).thenAnswer((_) async {});
          return authCubit;
        },
        act: (cubit) async {
          await cubit.loginWithEmail('user@abdoulexpress.com', 'password123');
          await cubit.logout();
          await cubit.loginWithEmail('user@abdoulexpress.com', 'password123');
        },
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
          isA<AuthUnauthenticated>(),
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'CONCURRENT: handles awaited sequential login attempts',
        build: () {
          when(() => mockRepository.loginWithEmail(
                  'user@abdoulexpress.com', 'password123'))
              .thenAnswer((_) async => 'mock_token_123');
          return authCubit;
        },
        act: (cubit) async {
          // Fire multiple login attempts sequentially (awaited)
          await cubit.loginWithEmail('user@abdoulexpress.com', 'password123');
          await cubit.loginWithEmail('user@abdoulexpress.com', 'password123');
        },
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'ERROR RECOVERY: can login after previous error',
        build: () {
          var callCount = 0;
          when(() => mockRepository.loginWithEmail(
                  'user@abdoulexpress.com', 'password123'))
              .thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              throw Exception('Network error');
            }
            return 'mock_token_123';
          });
          return authCubit;
        },
        act: (cubit) async {
          await cubit.loginWithEmail(
              'user@abdoulexpress.com', 'password123'); // Fails
          await cubit.loginWithEmail(
              'user@abdoulexpress.com', 'password123'); // Succeeds
        },
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
      );
    });
  });
}
