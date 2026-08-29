import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final box = Hive.box('settings');
    final isDark = box.get('isDarkMode', defaultValue: false);
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final box = Hive.box('settings');
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      box.put('isDarkMode', true);
    } else {
      state = ThemeMode.light;
      box.put('isDarkMode', false);
    }
  }
}
