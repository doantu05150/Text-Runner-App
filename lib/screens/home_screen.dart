import 'package:flutter/material.dart';
import '../services/locale_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/text_input_widget.dart';
import '../widgets/action_bar_widget.dart';
import '../widgets/preview_run_widget.dart';
import '../widgets/app_button.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_settings_dialog.dart';
import '../widgets/quick_themes_widget.dart';
import '../models/saved_item.dart';
import '../models/display_style.dart';
import '../models/home_text_settings.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../ads/global_inter_ad.dart';
import '../ads/home_bottom_native_ad.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController(
    text: 'Hello, GlowTextify!',
  );

  // Tracks soft-keyboard visibility so we can hide the bottom native ad
  // (it would otherwise overlay the home content) and force a fresh ad
  // load while the keyboard is up, so a new ad is ready by the time the
  // keyboard closes.
  bool _keyboardVisible = false;
  int _adReloadKey = 0;

  // Text settings (font, colors, speed, blink, …).
  HomeTextSettings _settings = HomeTextSettings(
    fontSize: 76,
    fontFamily: 'Orbitron',
    fontWeight: FontWeight.w700,
    textColor: Colors.pink,
    backgroundColor: AppColors.bgMain,
    speed: 250.0,
    displayStyle: DisplayStyle.normal,
    blinkText: false,
    blinkSpeed: 500.0,
  );

  static const double _inputFontSize = 18.0;
  static const double _minInputHeight = 56.0;
  static const double _verticalPadding = 34.0; // 16*2 contentPadding + 1*2 border

  // Input height
  double _inputHeight = _minInputHeight;

  // Preview (debounced)
  String _previewText = 'Hello, GlowTextify!';
  Timer? _debounceTimer;

  static const String _savedInterAdUnitId =
      'ca-app-pub-2729665939843867/6473280323';

  void _preloadSavedInterAd() {
    GlobalInterAd.loadAd(
      adUnitId: _savedInterAdUnitId,
      adPlacement: 'home_to_saved',
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _preloadSavedInterAd();
    // Warm the native ad cache so the home bottom ad — and the same
    // placement reused on the settings screen — render with no
    // visible load latency.
    HomeBottomNativeAd.preload();
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateInputHeight());
  }

  void _onTextChanged() {
    _updateInputHeight();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _previewText = _controller.text);
    });
  }

  void _updateInputHeight() {
    final text = _controller.text;
    if (text.isEmpty) {
      setState(() => _inputHeight = _minInputHeight);
      return;
    }

    final size = MediaQuery.of(context).size;
    final availableWidth = size.width - 40 - 32; // body + container padding

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: _inputFontSize, height: 1.2),
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: availableWidth);

    final lineCount = textPainter.computeLineMetrics().length;
    final contentHeight = (lineCount * _inputFontSize * 1.2) + _verticalPadding;

    setState(() {
      _inputHeight = contentHeight.clamp(
        _minInputHeight,
        _calculateMaxInputHeight().clamp(_minInputHeight, double.infinity),
      );
    });
  }

  double _calculateMaxInputHeight() {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final previewHeight = (size.width - 40) * size.width / size.height;
    return size.height
        - (kToolbarHeight + topPadding) // app bar
        - 8.0  // body top padding
        - 20.0 // body bottom padding
        - 40.0 // action bar
        - 12.0 // gap after action bar
        - previewHeight
        - 12.0 // gap after preview
        - 16.0 // gap after input
        - 56.0; // play button
  }

  Future<void> _saveText() async {
    final t = LocaleController.instance.strings;
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.enterTextToSave),
          backgroundColor: AppColors.bgCard,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedItemsJson = prefs.getStringList('saved_items') ?? [];

    final savedItem = SavedItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _controller.text,
      fontSize: _settings.fontSize,
      fontFamily: _settings.fontFamily,
      fontWeightValue: _settings.fontWeight.value,
      textColorValue: _settings.textColor.toARGB32(),
      backgroundColorValue: _settings.backgroundColor.toARGB32(),
      speed: _settings.speed,
      displayStyle: _settings.displayStyle.name,
      blinkText: _settings.blinkText,
      blinkSpeed: _settings.blinkSpeed,
      scrollText: _settings.scrollText,
      createdAt: DateTime.now(),
    );

    savedItemsJson.add(jsonEncode(savedItem.toJson()));
    await prefs.setStringList('saved_items', savedItemsJson);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(t.savedSuccess),
            ],
          ),
          backgroundColor: AppColors.bgCard,
        ),
      );
    }
  }

  void _startTextRunner() {
    if (_controller.text.isEmpty) {
      final t = LocaleController.instance.strings;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.enterTextToRun),
          backgroundColor: AppColors.bgCard,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/run',
      arguments: {
        'text': _controller.text,
        'fontSize': _settings.fontSize,
        'fontFamily': _settings.fontFamily,
        'textColor': _settings.textColor,
        'backgroundColor': _settings.backgroundColor,
        'fontWeight': _settings.fontWeight,
        'speed': _settings.speed,
        'displayStyle': _settings.displayStyle,
        'blinkText': _settings.blinkText,
        'blinkSpeed': _settings.blinkSpeed,
        'scrollText': _settings.scrollText,
      },
    );
  }

  Future<void> _openSettingsDialog() async {
    final result = await showHomeSettingsDialog(context, current: _settings);
    if (result != null && mounted) {
      setState(() => _settings = result);
    }
  }

  void _onSavedPressed() {
    void goToSaved(String? _) {
      if (!mounted) return;
      Navigator.pushNamed(context, '/saved');
      _preloadSavedInterAd();
    }

    if (GlobalInterAd.isReady) {
      GlobalInterAd.showAd(onDismissed: goToSaved);
    } else {
      // Not cached yet — just navigate and let the next visit
      // benefit from the preload that's already in flight.
      goToSaved(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocaleController.instance.code,
      builder: (context, _, __) {
        final t = LocaleController.instance.strings;
        return Scaffold(
          backgroundColor: AppColors.bgMain,
          appBar: HomeAppBar(
            onSavedPressed: _onSavedPressed,
            onSettingsPressed: () =>
                Navigator.pushNamed(context, '/settings'),
          ),
          body: LayoutBuilder(builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).padding.bottom;
            final adHeight = _keyboardVisible
                ? 0.0
                : HomeBottomNativeAd.heightForWidth(constraints.maxWidth);
            return Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, adHeight + bottomInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Action Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ActionBarWidget(
                              iconColor: AppColors.textSecondary,
                              onSettingsPressed: _openSettingsDialog,
                              onSavePressed: _saveText,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Preview
                        PreviewRunWidget(
                          text: _previewText,
                          fontSize: _settings.fontSize,
                          fontFamily: _settings.fontFamily,
                          fontWeight: _settings.fontWeight,
                          textColor: _settings.textColor,
                          backgroundColor: _settings.backgroundColor,
                          speed: _settings.speed,
                          displayStyle: _settings.displayStyle,
                          blinkText: _settings.blinkText,
                          blinkSpeed: _settings.blinkSpeed,
                          scrollText: _settings.scrollText,
                        ),
                        const SizedBox(height: 12),
                        // Quick Themes
                        QuickThemesGrid(
                          themes: QuickThemesGrid.defaultThemes,
                          currentTextColor: _settings.textColor,
                          currentBackgroundColor: _settings.backgroundColor,
                          currentDisplayStyle: _settings.displayStyle,
                          onSelected: (theme) {
                            setState(() {
                              _settings = _settings.copyWith(
                                backgroundColor: theme.backgroundColor,
                                textColor: theme.textColor,
                                displayStyle: DisplayStyle.led,
                              );
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        // Input section
                        TextInputWidget(
                          controller: _controller,
                          fontSize: _inputFontSize,
                          fontFamily: _settings.fontFamily,
                          textColor: AppColors.textPrimary,
                          inputHeight: _inputHeight,
                          verticalPadding: _verticalPadding,
                          onChanged: _onTextChanged,
                          shouldExpand: false,
                        ),
                        const SizedBox(height: 16),

                        // Play Button
                        AppButton(
                          onPressed: _startTextRunner,
                          icon: Icons.play_arrow_rounded,
                          child: Text(
                            t.run,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Offstage(
                    offstage: _keyboardVisible,
                    child: SafeArea(
                      top: false,
                      left: false,
                      right: false,
                      child: HomeBottomNativeAd(
                        key: ValueKey(_adReloadKey),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;
    final view = View.of(context);
    final newKeyboardVisible = view.viewInsets.bottom > 0;
    if (newKeyboardVisible == _keyboardVisible) return;
    setState(() {
      _keyboardVisible = newKeyboardVisible;
      // When the keyboard appears, hide the current ad and immediately
      // kick off a fresh load by bumping the widget key. The new ad
      // loads in the background while it's offstage, so it's ready to
      // be revealed the moment the keyboard goes away.
      if (newKeyboardVisible) _adReloadKey++;
    });
  }
}
