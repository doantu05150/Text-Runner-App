/// Configuration for reward-gated quick theme items.
class QuickItemsConfig {
  QuickItemsConfig._();

  /// 0-based indices of quick items that require watching a rewarded ad
  /// before they can be applied. Out-of-range indices are ignored.
  ///
  /// Only 4 quick items exist (indices 0–3).
  static const List<int> lockedQuickItems = [0, 1, 2, 3];

  static bool isLocked(int index) => lockedQuickItems.contains(index);
}
