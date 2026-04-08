import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A small preload cache for [NativeAd]s.
///
/// Holds at most one ready ad per (adUnitId, factoryId) key, plus at
/// most one in-flight load. [tryConsume] hands ownership of the cached
/// ad to the caller and immediately schedules a background refill so
/// the next consumer also gets a cache hit.
///
/// Notes / trade-offs:
///   * Wasted impressions are bounded: at any moment we can have at
///     most one ready ad and one in-flight load per key. Worst case at
///     app close: a single unconsumed ad.
///   * The cached ad is constructed inside the cache, so per-instance
///     listeners (onPaid, onClicked, onImpression) supplied later by a
///     consumer like `GlobalNativeAd` will NOT fire for cached ads.
///     This is acceptable for placements that don't subscribe to those
///     callbacks.
///   * Cached ads expire after [_maxAge] to stay under AdMob's native
///     ad freshness window (~1h).
class NativeAdCache {
  NativeAdCache._();

  static const Duration _maxAge = Duration(minutes: 50);

  static final Map<String, _Entry> _ready = {};
  static final Set<String> _loading = {};

  /// Ensures a NativeAd is being loaded for the given key. No-op if a
  /// fresh ad is already cached or a load is already in flight.
  static void preload({
    required String adUnitId,
    required String factoryId,
  }) {
    final key = _key(adUnitId, factoryId);
    if (_loading.contains(key)) return;
    final entry = _ready[key];
    if (entry != null && !entry.isExpired) return;
    _startLoad(key, adUnitId, factoryId);
  }

  /// Returns a cached NativeAd if one is ready, removing it from the
  /// cache. The caller takes ownership of the ad and is responsible for
  /// disposing it.
  ///
  /// Always schedules a background refill so the next consumer also
  /// benefits from a warm cache.
  static NativeAd? tryConsume({
    required String adUnitId,
    required String factoryId,
  }) {
    final key = _key(adUnitId, factoryId);
    final entry = _ready.remove(key);
    // Refill in the background for the next consumer.
    preload(adUnitId: adUnitId, factoryId: factoryId);
    if (entry == null) return null;
    if (entry.isExpired) {
      entry.ad.dispose();
      return null;
    }
    return entry.ad;
  }

  static void _startLoad(String key, String adUnitId, String factoryId) {
    _loading.add(key);
    NativeAd(
      adUnitId: adUnitId,
      factoryId: factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          _loading.remove(key);
          _ready[key] = _Entry(
            ad as NativeAd,
            DateTime.now().add(_maxAge),
          );
          debugPrint('[NativeAdCache] Preloaded $key');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError err) {
          _loading.remove(key);
          ad.dispose();
          debugPrint('[NativeAdCache] Preload failed for $key: $err');
        },
      ),
    ).load();
  }

  static String _key(String adUnitId, String factoryId) =>
      '$factoryId|$adUnitId';
}

class _Entry {
  _Entry(this.ad, this.expiresAt);

  final NativeAd ad;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
