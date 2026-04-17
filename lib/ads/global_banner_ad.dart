import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A self-contained banner ad widget.
///
/// Loads a [BannerAd] on mount and renders it once loaded.
/// Shows nothing ([SizedBox.shrink]) while loading or on failure.
class GlobalBannerAd extends StatefulWidget {
  const GlobalBannerAd({
    super.key,
    required this.adUnitId,
    this.size = AdSize.banner,
    this.adPlacement,
  });

  final String adUnitId;
  final AdSize size;
  final String? adPlacement;

  @override
  State<GlobalBannerAd> createState() => _GlobalBannerAdState();
}

class _GlobalBannerAdState extends State<GlobalBannerAd> {
  BannerAd? _bannerAd;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final ad = BannerAd(
      adUnitId: widget.adUnitId,
      size: widget.size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _bannerAd = ad as BannerAd);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('[GlobalBannerAd] Failed: $error');
          ad.dispose();
          if (!mounted) return;
          setState(() => _failed = true);
        },
      ),
    );
    ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _bannerAd;
    if (ad == null || _failed) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
