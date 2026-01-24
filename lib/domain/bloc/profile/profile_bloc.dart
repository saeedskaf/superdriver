import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:superdriver/domain/services/profile_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
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
      emit(ProfileLoaded(profileData: profileData));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    emit(const ProfileUpdating());
    try {
      final profileData = await profileService.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
      );
      emit(ProfileUpdateSuccess(profileData: profileData));
      emit(ProfileLoaded(profileData: profileData));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
      if (currentState is ProfileLoaded) {
        emit(ProfileLoaded(profileData: currentState.profileData));
      }
    }
  }

  Future<void> _onPasswordChangeRequested(
    PasswordChangeRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    emit(const PasswordChanging());
    try {
      await profileService.changePassword(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );
      emit(const PasswordChangeSuccess());
      if (currentState is ProfileLoaded) {
        emit(ProfileLoaded(profileData: currentState.profileData));
      }
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
      if (currentState is ProfileLoaded) {
        emit(ProfileLoaded(profileData: currentState.profileData));
      }
    }
  }
}
