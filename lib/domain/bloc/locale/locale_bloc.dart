// lib/domain/bloc/locale/locale_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';

part 'locale_event.dart';
part 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc() : super(LocaleState.initial()) {
    on<LocaleLoadRequested>(_onLoadRequested);
    on<LocaleChangeRequested>(_onChangeRequested);
    on<LocaleSetArabic>(_onSetArabic);
    on<LocaleSetEnglish>(_onSetEnglish);
  }

  Future<void> _onLoadRequested(
    LocaleLoadRequested event,
    Emitter<LocaleState> emit,
  ) async {
    final savedLocale = await secureStorage.getLocale();
    if (savedLocale != null) {
      emit(state.copyWith(locale: Locale(savedLocale)));
    }
  }

  Future<void> _onChangeRequested(
    LocaleChangeRequested event,
    Emitter<LocaleState> emit,
  ) async {
    await secureStorage.saveLocale(event.languageCode);
    emit(state.copyWith(locale: Locale(event.languageCode)));
  }

  Future<void> _onSetArabic(
    LocaleSetArabic event,
    Emitter<LocaleState> emit,
  ) async {
    await secureStorage.saveLocale('ar');
    emit(state.copyWith(locale: const Locale('ar')));
  }

  Future<void> _onSetEnglish(
    LocaleSetEnglish event,
    Emitter<LocaleState> emit,
  ) async {
    await secureStorage.saveLocale('en');
    emit(state.copyWith(locale: const Locale('en')));
  }
}
