import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool isVerified;
  final String? governorate;
  final String? role;
  final DateTime? dateJoined;
  final bool isOnline;
  final DateTime? lastOnline;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.isVerified = false,
    this.governorate,
    this.role,
    this.dateJoined,
    this.isOnline = false,
    this.lastOnline,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    String first = firstName.isNotEmpty ? firstName[0] : '';
    String last = lastName.isNotEmpty ? lastName[0] : '';
    return (first + last).toUpperCase();
  }

  /// Check if user has complete profile
  bool get hasCompleteProfile => firstName.isNotEmpty && lastName.isNotEmpty;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      isVerified: json['is_verified'] == true,
      governorate: json['governorate']?.toString(),
      role: json['role']?.toString(),
      dateJoined: json['date_joined'] != null
          ? DateTime.tryParse(json['date_joined'].toString())
          : null,
      isOnline: json['is_online'] == true,
      lastOnline: json['last_online'] != null
          ? DateTime.tryParse(json['last_online'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'is_verified': isVerified,
      'governorate': governorate,
      'role': role,
      'date_joined': dateJoined?.toIso8601String(),
      'is_online': isOnline,
      'last_online': lastOnline?.toIso8601String(),
    };
  }

  factory User.fromStorage(Map<String, String?> storage) {
    return User(
      id: storage['userId'] ?? '',
      firstName: storage['firstName'] ?? '',
      lastName: storage['lastName'] ?? '',
      phoneNumber: storage['phone'] ?? '',
      isVerified: storage['isVerified'] == 'true',
    );
  }

  /// Empty user for initial state
  factory User.empty() {
    return const User(id: '', firstName: '', lastName: '', phoneNumber: '');
  }

  /// Check if user is empty/not loaded
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isVerified,
    String? governorate,
    String? role,
    DateTime? dateJoined,
    bool? isOnline,
    DateTime? lastOnline,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isVerified: isVerified ?? this.isVerified,
      governorate: governorate ?? this.governorate,
      role: role ?? this.role,
      dateJoined: dateJoined ?? this.dateJoined,
      isOnline: isOnline ?? this.isOnline,
      lastOnline: lastOnline ?? this.lastOnline,
    );
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    phoneNumber,
    isVerified,
    governorate,
    role,
    dateJoined,
    isOnline,
    lastOnline,
  ];

  @override
  String toString() {
    return 'User(id: $id, name: $fullName, phone: $phoneNumber)';
  }
}
