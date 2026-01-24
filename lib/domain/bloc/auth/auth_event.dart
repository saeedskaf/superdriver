part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthRegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String phone;
  final String password;

  const AuthRegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [firstName, lastName, phone, password];
}

class AuthLoginRequested extends AuthEvent {
  final String phone;
  final String password;

  const AuthLoginRequested({required this.phone, required this.password});

  @override
  List<Object?> get props => [phone, password];
}

class AuthOtpVerificationRequested extends AuthEvent {
  final String phone;
  final String otp;
  final Map<String, dynamic>? userData;

  const AuthOtpVerificationRequested({
    required this.phone,
    required this.otp,
    this.userData,
  });

  @override
  List<Object?> get props => [phone, otp, userData];
}

class AuthResendOtpRequested extends AuthEvent {
  final String phone;
  final String otpType; // 'signup' or 'reset_password'

  const AuthResendOtpRequested({required this.phone, required this.otpType});

  @override
  List<Object?> get props => [phone, otpType];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String phone;

  const AuthResetPasswordRequested({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class AuthPasswordResetConfirmed extends AuthEvent {
  final String phone;
  final String otpCode;
  final String newPassword;
  final String confirmPassword;

  const AuthPasswordResetConfirmed({
    required this.phone,
    required this.otpCode,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [phone, otpCode, newPassword, confirmPassword];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}
