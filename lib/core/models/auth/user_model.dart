// File: lib/core/models/auth/user_model.dart

/// User Role Enum
enum UserRole {
  customer('customer'),
  admin('admin'),
  doctor('doctor'),
  nurse('nurse'),
  pharmacist('pharmacist'),
  labTechnician('lab_technician'),
  receptionist('receptionist');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.customer,
    );
  }
}

/// User Status Enum
enum UserStatus {
  active('active'),
  inactive('inactive'),
  suspended('suspended'),
  banned('banned');

  final String value;
  const UserStatus(this.value);

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => UserStatus.active,
    );
  }
}

/// Verification Status Enum
enum VerificationStatus {
  unverified('unverified'),
  pending('pending'),
  verified('verified'),
  rejected('rejected');

  final String value;
  const VerificationStatus(this.value);
}

/// User Model Class
class UserModel {
  final String id;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String? address;
  final String? profileImageUrl;
  final UserRole role;
  final UserStatus status;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? region; // Specific for Ethiopian context

  UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.address,
    this.profileImageUrl,
    this.role = UserRole.customer,
    this.status = UserStatus.active,
    this.verificationStatus = VerificationStatus.verified,
    required this.createdAt,
    this.updatedAt,
    this.region,
  });

  /// Get full display name
  String get displayName => '$firstName $lastName'.trim();

  /// Get role display name
  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.nurse:
        return 'Nurse';
      case UserRole.customer:
        return 'Customer';
      default:
        return role.value.toUpperCase();
    }
  }

  /// Factory method to create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle name splitting if full name is provided
    String fName = '';
    String lName = '';

    if (json['name'] != null) {
      final nameParts = (json['name'] as String).split(' ');
      if (nameParts.isNotEmpty) {
        fName = nameParts.first;
        if (nameParts.length > 1) {
          lName = nameParts.sublist(1).join(' ');
        }
      }
    } else {
      fName = json['firstName'] ?? '';
      lName = json['lastName'] ?? '';
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      firstName: fName,
      lastName: lName,
      address: json['address'],
      profileImageUrl: json['profileImage'],
      role: UserRole.fromString(json['type'] ?? json['role'] ?? 'customer'),
      status: UserStatus.fromString(json['status'] ?? 'active'),
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.value == (json['verificationStatus'] ?? 'verified'),
        orElse: () => VerificationStatus.verified,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      region: json['region'],
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'name': displayName,
      'address': address,
      'profileImage': profileImageUrl,
      'role': role.value,
      'type': role.value, // For API compatibility
      'status': status.value,
      'verificationStatus': verificationStatus.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'region': region,
    };
  }

  // --- Permission Helpers ---

  bool get hasAdminAccess => role == UserRole.admin;

  bool get hasFinanceAccess =>
      role == UserRole.admin || role == UserRole.receptionist;

  bool get canManageAppointments =>
      role == UserRole.admin ||
      role == UserRole.receptionist ||
      role == UserRole.doctor;

  bool get canProvideServices =>
      role == UserRole.doctor ||
      role == UserRole.nurse ||
      role == UserRole.pharmacist ||
      role == UserRole.labTechnician;

  bool get canProvideSupport =>
      role == UserRole.admin || role == UserRole.receptionist;
}
