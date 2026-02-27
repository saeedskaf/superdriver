part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profileData;

  const ProfileLoaded({required this.profileData});

  String get firstName {
    return (profileData['first_name'] ?? '').toString();
  }

  String get lastName {
    return (profileData['last_name'] ?? '').toString();
  }

  String get fullName => '$firstName $lastName'.trim();

  String get phoneNumber {
    return (profileData['phone_number'] ?? '').toString();
  }

  String get initials {
    String first = firstName.isNotEmpty ? firstName[0] : '';
    String last = lastName.isNotEmpty ? lastName[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  List<Object?> get props => [profileData];
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

class ProfileUpdateSuccess extends ProfileState {
  final Map<String, dynamic> profileData;

  const ProfileUpdateSuccess({required this.profileData});

  @override
  List<Object?> get props => [profileData];
}

class PasswordChanging extends ProfileState {
  const PasswordChanging();
}

class PasswordChangeSuccess extends ProfileState {
  const PasswordChangeSuccess();
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
