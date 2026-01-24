// lib/domain/bloc/locale/locale_state.dart

part of 'locale_bloc.dart';

class LocaleState extends Equatable {
  final Locale locale;

  const LocaleState({required this.locale});

  // Default state with Arabic locale
  factory LocaleState.initial() => const LocaleState(locale: Locale('ar'));

  bool get isArabic => locale.languageCode == 'ar';
  bool get isEnglish => locale.languageCode == 'en';

  LocaleState copyWith({Locale? locale}) {
    return LocaleState(locale: locale ?? this.locale);
  }

  @override
  List<Object?> get props => [locale];
}
