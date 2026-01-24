// lib/domain/bloc/locale/locale_event.dart

part of 'locale_bloc.dart';

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

class LocaleLoadRequested extends LocaleEvent {
  const LocaleLoadRequested();
}

class LocaleChangeRequested extends LocaleEvent {
  final String languageCode;

  const LocaleChangeRequested({required this.languageCode});

  @override
  List<Object?> get props => [languageCode];
}

class LocaleSetArabic extends LocaleEvent {
  const LocaleSetArabic();
}

class LocaleSetEnglish extends LocaleEvent {
  const LocaleSetEnglish();
}
