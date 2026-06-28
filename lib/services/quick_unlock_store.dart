import 'package:shared_preferences/shared_preferences.dart';

/// Persists which reward-gated quick items have been unlocked, scoped to the
/// current calendar day. Unlocks reset automatically on the next day.
class QuickUnlockStore {
  QuickUnlockStore._();

  static const String _dateKey = 'quick_unlocked_date';
  static const String _indicesKey = 'quick_unlocked_indices';

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  /// Returns the set of quick item indices unlocked today. If the stored date
  /// is from a previous day, the stored unlocks are cleared and an empty set
  /// is returned.
  static Future<Set<int>> loadUnlockedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDate = prefs.getString(_dateKey);
    if (storedDate != _today()) {
      await prefs.remove(_dateKey);
      await prefs.remove(_indicesKey);
      return <int>{};
    }
    final raw = prefs.getStringList(_indicesKey) ?? const [];
    return raw.map(int.tryParse).whereType<int>().toSet();
  }

  /// Marks [index] as unlocked for today and returns the updated set.
  static Future<Set<int>> markUnlocked(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadUnlockedToday();
    current.add(index);
    await prefs.setString(_dateKey, _today());
    await prefs.setStringList(
      _indicesKey,
      current.map((e) => e.toString()).toList(),
    );
    return current;
  }
}
