import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_provider.g.dart';

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    return const Locale('es'); // Default locale
  }

  void setLocale(Locale locale) {
    if (['es', 'en', 'ca'].contains(locale.languageCode)) {
      state = locale;
    }
  }
}
