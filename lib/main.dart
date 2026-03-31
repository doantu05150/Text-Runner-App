import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/run_screen.dart';
import 'screens/saved_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bgMain,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Runner',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => const HomeScreen());
        } else if (settings.name == '/saved') {
          return MaterialPageRoute(builder: (context) => const SavedScreen());
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
            ),
          );
        }
        return null;
      },
    );
  }
}
