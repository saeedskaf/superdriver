part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  final String? firstName;
  final String? lastName;

  const ProfileUpdateRequested({this.firstName, this.lastName});

  @override
  List<Object?> get props => [firstName, lastName];
}

class PasswordChangeRequested extends ProfileEvent {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const PasswordChangeRequested({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword, confirmPassword];
}
