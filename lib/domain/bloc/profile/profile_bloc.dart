// lib/domain/bloc/profile/profile_bloc.dart
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:superdriver/data/services/profile_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  Map<String, dynamic>? _lastProfileData;

  ProfileBloc() : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<PasswordChangeRequested>(_onPasswordChangeRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final profileData = await profileService.getProfile();
      log('ProfileBloc: data received: $profileData');
      _lastProfileData = profileData;
      emit(ProfileLoaded(profileData: profileData));
    } catch (e) {
      log('ProfileBloc: Error: $e');
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileUpdating());
    try {
      final profileData = await profileService.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
      );
      _lastProfileData = profileData;
      emit(ProfileUpdateSuccess(profileData: profileData));
      // Restore to loaded state so UI can continue operating
      emit(ProfileLoaded(profileData: profileData));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
      if (_lastProfileData != null) {
        emit(ProfileLoaded(profileData: _lastProfileData!));
      }
    }
  }

  Future<void> _onPasswordChangeRequested(
    PasswordChangeRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const PasswordChanging());
    try {
      await profileService.changePassword(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );
      emit(const PasswordChangeSuccess());
      if (_lastProfileData != null) {
        emit(ProfileLoaded(profileData: _lastProfileData!));
      }
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
      if (_lastProfileData != null) {
        emit(ProfileLoaded(profileData: _lastProfileData!));
      }
    }
  }
}
