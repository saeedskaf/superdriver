class User {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool isVerified;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.isVerified,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    String first = firstName.isNotEmpty ? firstName[0] : '';
    String last = lastName.isNotEmpty ? lastName[0] : '';
    return (first + last).toUpperCase();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      isVerified: json['is_verified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'is_verified': isVerified,
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

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
