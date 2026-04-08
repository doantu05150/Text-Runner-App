import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';

class LocaleController {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  static const String _prefsKey = 'lang_code';

  final ValueNotifier<String> code = ValueNotifier(AppStrings.defaultCode);

  AppStrings get strings => AppStrings.of(code.value);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null &&
        AppStrings.supported.any((o) => o.code == saved)) {
      code.value = saved;
    }
  }

  Future<void> setCode(String newCode) async {
    if (!AppStrings.supported.any((o) => o.code == newCode)) return;
    code.value = newCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, newCode);
  }
}
