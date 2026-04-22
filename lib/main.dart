import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/run_screen.dart';
import 'screens/splash_screen.dart';
import 'models/display_style.dart';
import 'ads/global_app_open_ad.dart';
import 'services/locale_controller.dart';
import 'services/theme_controller.dart';
import 'theme/app_theme.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await ThemeController.instance.load();
  await LocaleController.instance.load();
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      maxAdContentRating: MaxAdContentRating.t,
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
    ),
  );
  unawaited(MobileAds.instance.initialize());
  GlobalAppOpenAd.instance.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeMode,
      builder: (context, mode, _) => ValueListenableBuilder<String>(
        valueListenable: LocaleController.instance.code,
        builder: (context, langCode, __) => MaterialApp(
      title: 'GlowTextify LED',
      theme: AppTheme.current,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        if (settings.name == '/splash') {
          return MaterialPageRoute(builder: (context) => const SplashScreen());
        } else if (settings.name == '/onboarding/1') {
          return MaterialPageRoute(
              builder: (context) => const OnboardingPage1());
        } else if (settings.name == '/onboarding/2') {
          return MaterialPageRoute(
              builder: (context) => const OnboardingPage2());
        } else if (settings.name == '/onboarding/3') {
          return MaterialPageRoute(
              builder: (context) => const OnboardingPage3());
        } else if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => const MainShell());
        } else if (settings.name == '/run') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => RunScreen(
              text: args['text'] as String,
              fontSize: args['fontSize'] as double,
              fontFamily: args['fontFamily'] as String,
              fontWeight: args['fontWeight'] as FontWeight? ?? FontWeight.normal,
              textColor: args['textColor'] as Color,
              backgroundColor: args['backgroundColor'] as Color,
              speed: args['speed'] as double? ?? 150.0,
              displayStyle: args['displayStyle'] as DisplayStyle? ?? DisplayStyle.normal,
              blinkText: args['blinkText'] as bool? ?? false,
              blinkSpeed: args['blinkSpeed'] as double? ?? 500.0,
              scrollText: args['scrollText'] as bool? ?? true,
            ),
          );
        }
        return null;
      },
        ),
      ),
    );
  }
}
