/// Mock users for testing authentication
class MockUsers {
  static const validUser1 = {
    'id': 'user-1',
    'email': 'user@abdoulexpress.com',
    'password': 'password123',
    'phone': '+22790123456',
    'firstName': 'Abdoul',
    'lastName': 'Karim',
  };

  static const validUser2 = {
    'id': 'user-2',
    'email': 'test@test.com',
    'password': '123456',
    'phone': '+22790654321',
    'firstName': 'Test',
    'lastName': 'User',
  };

  static const adminUser = {
    'id': 'admin-1',
    'email': 'admin@abdoulexpress.com',
    'password': 'admin123',
    'phone': '+22790111111',
    'firstName': 'Admin',
    'lastName': 'User',
    'role': 'admin',
  };

  /// Valid credentials for login testing
  static const validCredentials = [
    {
      'email': 'user@abdoulexpress.com',
      'password': 'password123',
    },
    {
      'email': 'test@test.com',
      'password': '123456',
    },
  ];

  /// Invalid credentials for testing
  static const invalidCredentials = [
    {
      'email': 'wrong@example.com',
      'password': 'wrongpassword',
    },
    {
      'email': 'user@abdoulexpress.com',
      'password': 'wrongpassword',
    },
    {
      'email': 'invalid-email',
      'password': 'password123',
    },
  ];

  /// Valid phone numbers
  static const validPhoneNumbers = [
    '+22790123456',
    '+22790654321',
    '+22791234567',
  ];

  /// Invalid phone numbers
  static const invalidPhoneNumbers = [
    '1234567',
    '+1234567890',
    'not-a-phone',
    '',
  ];

  /// Valid OTP codes for testing
  static const validOtp = '123456';
  static const invalidOtp = '000000';

  /// Check if user credentials are valid
  static bool isValidCredentials(String email, String password) {
    return validCredentials.any(
      (cred) => cred['email'] == email && cred['password'] == password,
    );
  }

  /// Check if email exists
  static bool emailExists(String email) {
    return validCredentials.any((cred) => cred['email'] == email);
  }

  /// Check if phone is valid Niger format
  static bool isValidNigerPhone(String phone) {
    return validPhoneNumbers.contains(phone) ||
        RegExp(r'^\+227\d{8}$').hasMatch(phone);
  }
}
