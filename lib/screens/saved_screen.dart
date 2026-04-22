import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../ads/ad_ids.dart';
import '../ads/global_banner_ad.dart';
import '../l10n/app_strings.dart';
import '../services/locale_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../models/saved_item.dart';
import '../models/display_style.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => SavedScreenState();
}

class SavedScreenState extends State<SavedScreen> {
  List<SavedItem> _savedItems = [];
  bool _isLoading = true;
  bool _adReady = true;

  @override
  void initState() {
    super.initState();
    _loadSavedItems();
  }

  void reload() => _loadSavedItems();

  Future<void> _loadSavedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final savedItemsJson = prefs.getStringList('saved_items') ?? [];
    setState(() {
      _savedItems = savedItemsJson
          .map((json) => SavedItem.fromJson(jsonDecode(json)))
          .toList()
          .reversed
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _removeItem(int index) async {
    final removedItem = _savedItems[index];
    setState(() => _savedItems.removeAt(index));

    final prefs = await SharedPreferences.getInstance();
    final allJson = prefs.getStringList('saved_items') ?? [];
    allJson.removeWhere((json) {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return decoded['id'] == removedItem.id;
    });
    await prefs.setStringList('saved_items', allJson);
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }

  String _fontWeightLabel(int value) {
    switch (value) {
      case 100: return 'Thin';
      case 300: return 'Light';
      case 400: return 'Regular';
      case 500: return 'Medium';
      case 700: return 'Bold';
      case 900: return 'Black';
      default: return 'w$value';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocaleController.instance.code,
      builder: (context, _, __) {
        final AppStrings t = LocaleController.instance.strings;
        return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Text(
          t.saved,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _savedItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.bookmark_border_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.noItemsYet,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.savedTextsWillAppear,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _savedItems.length + (_adReady ? 1 : 0),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (_adReady && index == 1) {
                      return Center(
                        child: GlobalBannerAd(
                          adUnitId: AdIds.savedListBanner,
                          adPlacement: 'saved_list',
                          onAdReady: (ready) {
                            if (!ready && mounted) setState(() => _adReady = false);
                          },
                        ),
                      );
                    }
                    final itemIndex = (_adReady && index > 1) ? index - 1 : index;
                    final item = _savedItems[itemIndex];
                    final textColor = Color(item.textColorValue);
                    final bgColor = Color(item.backgroundColorValue);
                    return AppCard(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/run',
                          arguments: {
                            'text': item.text,
                            'fontSize': item.fontSize,
                            'fontFamily': item.fontFamily,
                            'fontWeight': FontWeight.values.firstWhere(
                              (w) => w.value == item.fontWeightValue,
                              orElse: () => FontWeight.normal,
                            ),
                            'textColor': textColor,
                            'backgroundColor': bgColor,
                            'speed': item.speed,
                            'displayStyle': DisplayStyle.values.byName(item.displayStyle),
                            'blinkText': item.blinkText,
                            'blinkSpeed': item.blinkSpeed,
                            'scrollText': item.scrollText,
                          },
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.text,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _removeItem(itemIndex),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                    color: Colors.red.shade300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _chip('${item.fontSize.toInt()}px'),
                                const SizedBox(width: 6),
                                _chip(item.fontFamily),
                                const SizedBox(width: 6),
                                _colorChip(textColor, t.textLabel),
                                const SizedBox(width: 6),
                                _colorChip(bgColor, t.bgLabel),
                                const SizedBox(width: 6),
                                _chip('${item.speed.toInt()} px/s'),
                                const SizedBox(width: 6),
                                _chip(_fontWeightLabel(item.fontWeightValue)),
                                const SizedBox(width: 6),
                                _chip(item.displayStyle == 'led' ? 'LED' : t.normal),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDate(item.createdAt),
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
      },
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.bgMain,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }

  Widget _colorChip(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.bgMain,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

