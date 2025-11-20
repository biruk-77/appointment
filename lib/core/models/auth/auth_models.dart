// File: lib/core/models/auth/auth_models.dart

/// Request model for login
class LoginRequest {
  final String identifier; // Usually email
  final String password;

  LoginRequest({required this.identifier, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': identifier, 'password': password};
  }
}

/// Request model for registration
class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String? address;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': '$firstName $lastName'.trim(),
      'email': email,
      'phone': phone,
      'password': password,
      'address': address,
    };
  }
}

/// Request model for OTP verification
class OTPVerificationRequest {
  final String identifier;
  final String otp;
  final String purpose;

  OTPVerificationRequest({
    required this.identifier,
    required this.otp,
    this.purpose = 'login',
  });

  Map<String, dynamic> toJson() {
    return {'identifier': identifier, 'otp': otp, 'purpose': purpose};
  }
}

/// Request model for password reset
class PasswordResetRequest {
  final String identifier;

  PasswordResetRequest({required this.identifier});

  Map<String, dynamic> toJson() {
    return {'email': identifier};
  }
}

/// Request model for changing password
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'currentPassword': currentPassword, 'newPassword': newPassword};
  }
}
