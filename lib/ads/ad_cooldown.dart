/// Shared cooldown tracker for full-screen ads (App Open + Interstitial).
///
/// Records whenever any full-screen ad is shown so that different ad types
/// can enforce a minimum gap between each other.
class AdCooldown {
  AdCooldown._();

  static DateTime? _lastFullScreenShownAt;

  /// Minimum gap between any two full-screen ads of different types.
  static const Duration crossAdGap = Duration(seconds: 30);

  /// Returns true if a full-screen ad was shown less than [crossAdGap] ago.
  static bool get isCoolingDown {
    final last = _lastFullScreenShownAt;
    if (last == null) return false;
    return DateTime.now().difference(last) < crossAdGap;
  }

  /// Call this immediately when a full-screen ad appears on screen.
  static void recordShown() {
    _lastFullScreenShownAt = DateTime.now();
  }
}
