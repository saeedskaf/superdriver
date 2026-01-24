import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/models/user_model.dart';
import 'package:superdriver/domain/services/auth_services.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthOtpVerificationRequested>(_onOtpVerificationRequested);
    on<AuthResendOtpRequested>(_onResendOtpRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthPasswordResetConfirmed>(_onPasswordResetConfirmed);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckStatus>(_onCheckStatus);
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await authServices.register(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        password: event.password,
        confirmPassword: event.password,
      );

      final String phoneNumber =
          response['phone_number']?.toString() ?? event.phone;

      emit(
        AuthOtpSent(
          phone: phoneNumber,
          verificationId: 'signup_otp',
          userData: {
            'firstName': event.firstName,
            'lastName': event.lastName,
            'phone': phoneNumber,
            'password': event.password,
          },
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await authServices.login(event.phone, event.password);

      // Validate response structure
      if (response['tokens'] == null || response['user'] == null) {
        throw Exception('Invalid server response');
      }

      // Extract tokens safely
      final tokens = response['tokens'] as Map<String, dynamic>;
      final String accessToken = tokens['access']?.toString() ?? '';
      final String refreshToken = tokens['refresh']?.toString() ?? '';

      if (accessToken.isEmpty) {
        throw Exception('No access token received');
      }

      // Create User model from response
      final userJson = response['user'] as Map<String, dynamic>;
      final user = User.fromJson(userJson);

      // Save all data to secure storage
      await secureStorage.saveUserData(
        accessToken: accessToken,
        refreshToken: refreshToken,
        phone: user.phoneNumber,
        firstName: user.firstName,
        lastName: user.lastName,
        userId: user.id,
        isVerified: user.isVerified,
      );

      // Emit authenticated state with User model
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onOtpVerificationRequested(
    AuthOtpVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authServices.verifyOtp(
        phone: event.phone,
        otpCode: event.otp,
        otpType: 'signup',
      );

      final userData = event.userData;
      if (userData != null) {
        // Registration flow - just verify OTP
        emit(const AuthRegistrationSuccess());
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onResendOtpRequested(
    AuthResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authServices.resendOtp(phone: event.phone, otpType: event.otpType);
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authServices.forgotPassword(phone: event.phone);
      emit(AuthResetCodeSent(phone: event.phone));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onPasswordResetConfirmed(
    AuthPasswordResetConfirmed event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authServices.resetPassword(
        phone: event.phone,
        otpCode: event.otpCode,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );
      emit(const AuthPasswordResetSuccess());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await secureStorage.clearAuthData();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await secureStorage.isLoggedInAndVerified();
    if (isLoggedIn) {
      final userData = await secureStorage.getUserData();
      final user = User.fromStorage(userData);
      emit(AuthAuthenticated(user: user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
