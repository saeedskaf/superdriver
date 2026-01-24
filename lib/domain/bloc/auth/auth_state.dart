part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthOtpSent extends AuthState {
  final String phone;
  final String verificationId;
  final Map<String, dynamic>? userData;

  const AuthOtpSent({
    required this.phone,
    required this.verificationId,
    this.userData,
  });

  @override
  List<Object?> get props => [phone, verificationId, userData];
}

class AuthResetCodeSent extends AuthState {
  final String phone;

  const AuthResetCodeSent({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class AuthPasswordResetSuccess extends AuthState {
  const AuthPasswordResetSuccess();
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];

  // Helper getters for backward compatibility
  String get userId => user.id;
  String get phone => user.phoneNumber;
  String get firstName => user.firstName;
  String get lastName => user.lastName;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthRegistrationSuccess extends AuthState {
  const AuthRegistrationSuccess();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
