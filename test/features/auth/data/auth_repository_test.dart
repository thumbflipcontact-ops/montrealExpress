import 'package:flutter_test/flutter_test.dart';
import 'package:abdoul_express/features/auth/data/auth_repository.dart';

/// Tests for AuthRepository
///
/// This test suite covers:
/// - Email/Password login
/// - Phone/OTP login
/// - Signup
/// - Session management
/// - Edge cases
///
/// Total: 22 tests
void main() {
  late AuthRepository repository;

  setUp(() {
    repository = AuthRepository();
  });

  tearDown(() async {
    // Clean up after each test
    await repository.logout();
  });

  group('AuthRepository -', () {
    group('Email/Password Login |', () {
      test('SUCCESS: returns token for valid credentials', () async {
        // Arrange
        const email = 'user@abdoulexpress.com';
        const password = 'password123';

        // Act
        final token = await repository.loginWithEmail(email, password);

        // Assert
        expect(token, isNotNull);
        expect(token, isA<String>());
        expect(token.startsWith('mock_token_'), true);

        // Verify session is active
        final isAuthenticated = await repository.checkAuthStatus();
        expect(isAuthenticated, true);
      });

      test('SUCCESS: returns token for alternative valid user', () async {
        // Arrange
        const email = 'test@test.com';
        const password = '123456';

        // Act
        final token = await repository.loginWithEmail(email, password);

        // Assert
        expect(token, isNotNull);
        expect(token, isA<String>());
      });

      test('FAILURE: throws exception for invalid email', () async {
        // Arrange
        const email = 'invalid@example.com';
        const password = 'password123';

        // Act & Assert
        expect(
          () => repository.loginWithEmail(email, password),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('incorrect')),
          ),
        );
      });

      test('FAILURE: throws exception for invalid password', () async {
        // Arrange
        const email = 'user@ibnahmad.com';
        const password = 'wrongpassword';

        // Act & Assert
        expect(
          () => repository.loginWithEmail(email, password),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('incorrect')),
          ),
        );
      });

      test('VALIDATION: empty email still processes (no client validation)',
          () async {
        // Arrange
        const email = '';
        const password = 'password123';

        // Act & Assert - Repository doesn't validate, just checks mock users
        expect(
          () => repository.loginWithEmail(email, password),
          throwsA(isA<Exception>()),
        );
      });

      test(
          'VALIDATION: empty password still processes (no client validation)',
          () async {
        // Arrange
        const email = 'user@abdoulexpress.com';
        const password = '';

        // Act & Assert - Repository doesn't validate format, just checks mock users
        expect(
          () => repository.loginWithEmail(email, password),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Phone/OTP Login |', () {
      test('SUCCESS: successfully initiates phone login', () async {
        // Arrange
        const phone = '+22790123456';

        // Act & Assert
        expect(
          () => repository.loginWithPhone(phone),
          returnsNormally,
        );
      });

      test('SUCCESS: returns token for valid OTP', () async {
        // Arrange
        const phone = '+22790123456';
        const otp = '123456';
        await repository.loginWithPhone(phone);

        // Act
        final token = await repository.verifyOtp(otp);

        // Assert
        expect(token, isNotNull);
        expect(token, isA<String>());
        expect(token.startsWith('mock_token_'), true);

        // Verify session is active
        final isAuthenticated = await repository.checkAuthStatus();
        expect(isAuthenticated, true);
      });

      test('FAILURE: throws exception for invalid OTP', () async {
        // Arrange
        const phone = '+22790123456';
        const invalidOtp = '000000';
        await repository.loginWithPhone(phone);

        // Act & Assert
        expect(
          () => repository.verifyOtp(invalidOtp),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('incorrect')),
          ),
        );
      });

      test('VALIDATION: empty OTP throws exception', () async {
        // Arrange
        const phone = '+22790123456';
        const otp = '';
        await repository.loginWithPhone(phone);

        // Act & Assert
        expect(
          () => repository.verifyOtp(otp),
          throwsA(isA<Exception>()),
        );
      });

      test('IDEMPOTENT: can call loginWithPhone multiple times', () async {
        // Arrange
        const phone = '+22790123456';

        // Act
        await repository.loginWithPhone(phone);
        await repository.loginWithPhone(phone);

        // Assert - should not throw
        expect(
          () => repository.loginWithPhone(phone),
          returnsNormally,
        );
      });
    });

    group('Signup |', () {
      test('SUCCESS: returns token for valid signup data', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'newpass123';

        // Act
        final token = await repository.signupWithEmail(email, password);

        // Assert
        expect(token, isNotNull);
        expect(token, isA<String>());
        expect(token.startsWith('mock_token_'), true);

        // Verify session is active
        final isAuthenticated = await repository.checkAuthStatus();
        expect(isAuthenticated, true);
      });

      test('FAILURE: throws exception for existing email', () async {
        // Arrange
        const email = 'user@abdoulexpress.com'; // Already exists
        const password = 'newpass123';

        // Act & Assert
        expect(
          () => repository.signupWithEmail(email, password),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('déjà utilisé')),
          ),
        );
      });

      test('SUCCESS: can signup with weak password (no validation)',
          () async {
        // Arrange
        const email = 'newuser2@example.com';
        const password = '123'; // Weak password

        // Act
        final token = await repository.signupWithEmail(email, password);

        // Assert - Repository doesn't validate password strength
        expect(token, isNotNull);
      });

      test('SUCCESS: can signup then login with new credentials', () async {
        // Arrange
        const email = 'newuser3@example.com';
        const password = 'newpass123';

        // Act - Signup
        final signupToken = await repository.signupWithEmail(email, password);
        expect(signupToken, isNotNull);

        // Logout
        await repository.logout();

        // Login with same credentials
        final loginToken = await repository.loginWithEmail(email, password);

        // Assert
        expect(loginToken, isNotNull);
        expect(loginToken, isA<String>());
      });
    });

    group('Session Management |', () {
      test('SUCCESS: returns true when user is logged in', () async {
        // Arrange
        await repository.loginWithEmail(
          'user@abdoulexpress.com',
          'password123',
        );

        // Act
        final isAuthenticated = await repository.checkAuthStatus();

        // Assert
        expect(isAuthenticated, true);
      });

      test('SUCCESS: returns false when no user is logged in', () async {
        // Arrange
        await repository.logout();

        // Act
        final isAuthenticated = await repository.checkAuthStatus();

        // Assert
        expect(isAuthenticated, false);
      });

      test('SUCCESS: successfully logs out user', () async {
        // Arrange
        await repository.loginWithEmail(
          'user@abdoulexpress.com',
          'password123',
        );
        var isAuthenticated = await repository.checkAuthStatus();
        expect(isAuthenticated, true);

        // Act
        await repository.logout();
        isAuthenticated = await repository.checkAuthStatus();

        // Assert
        expect(isAuthenticated, false);
      });

      test('IDEMPOTENT: logout works even when not logged in', () async {
        // Act & Assert
        expect(
          () => repository.logout(),
          returnsNormally,
        );
      });

      test('PERSISTENT: session persists across multiple checks', () async {
        // Arrange
        await repository.loginWithEmail(
          'user@abdoulexpress.com',
          'password123',
        );

        // Act - Check multiple times
        final check1 = await repository.checkAuthStatus();
        final check2 = await repository.checkAuthStatus();
        final check3 = await repository.checkAuthStatus();

        // Assert - Should remain authenticated
        expect(check1, true);
        expect(check2, true);
        expect(check3, true);
      });
    });

    group('Edge Cases |', () {
      test('SECURITY: password is case sensitive', () async {
        // Arrange
        const email = 'user@abdoulexpress.com';
        const correctPassword = 'password123';
        const wrongCasePassword = 'PASSWORD123';

        // Act - Correct password should work
        final correctToken =
            await repository.loginWithEmail(email, correctPassword);
        expect(correctToken, isNotNull);

        await repository.logout();

        // Act - Wrong case should fail
        expect(
          () => repository.loginWithEmail(email, wrongCasePassword),
          throwsA(isA<Exception>()),
        );
      });

      test('SECURITY: email is case sensitive in mock implementation',
          () async {
        // Arrange
        const emailLower = 'user@abdoulexpress.com';
        const emailUpper = 'USER@ABDOULEXPRESS.COM';
        const password = 'password123';

        // Act - Lowercase works
        final tokenLower =
            await repository.loginWithEmail(emailLower, password);
        expect(tokenLower, isNotNull);

        await repository.logout();

        // Act - Uppercase fails (mock uses exact match)
        expect(
          () => repository.loginWithEmail(emailUpper, password),
          throwsA(isA<Exception>()),
        );
      });

      test('CONCURRENT: handles sequential login attempts', () async {
        // Arrange
        const email = 'user@abdoulexpress.com';
        const password = 'password123';

        // Act - Sequential logins (awaited)
        final token1 = await repository.loginWithEmail(email, password);
        final token2 = await repository.loginWithEmail(email, password);
        final token3 = await repository.loginWithEmail(email, password);

        // Assert - All should succeed, tokens are different
        expect(token1, isNotNull);
        expect(token2, isNotNull);
        expect(token3, isNotNull);
        expect(token1 != token2, true); // Each login generates new token
        expect(token2 != token3, true);
      });

      test('TOKEN: each login generates unique token', () async {
        // Arrange
        const email = 'user@abdoulexpress.com';
        const password = 'password123';

        // Act
        final token1 = await repository.loginWithEmail(email, password);
        await repository.logout();

        // Small delay to ensure different timestamp
        await Future.delayed(const Duration(milliseconds: 10));

        final token2 = await repository.loginWithEmail(email, password);

        // Assert - Tokens should be different (timestamp-based)
        expect(token1, isNotNull);
        expect(token2, isNotNull);
        expect(token1 != token2, true);
      });
    });
  });
}
