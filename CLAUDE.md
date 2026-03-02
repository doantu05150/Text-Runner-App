# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on a connected device/emulator
flutter run

# Run on a specific platform
flutter run -d windows
flutter run -d chrome

# Build
flutter build apk
flutter build windows

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze for lint issues
flutter analyze

# Get dependencies
flutter pub get
```

## Architecture

**Text Runner** is a Flutter app (landscape-only) that scrolls text horizontally across the screen like a ticker/marquee display.

### Navigation & Data Flow

The app uses named routes defined in `main.dart`. `/run` accepts a `Map<String, dynamic>` argument with keys: `text`, `fontSize`, `fontFamily`, `textColor`, `backgroundColor`, `speed`.

```
HomeScreen (/) → RunScreen (/run)  [pass text + style settings]
HomeScreen (/) → SavedScreen (/saved)
```

### Key Files

- **`lib/text_runner.dart`** — `TextRunner` class with a `run()` Stream that reveals text character-by-character. Currently unused by `RunScreen` (which uses `AnimationController` instead for scrolling).
- **`lib/screens/run_screen.dart`** — Scrolls text right-to-left using `AnimationController`. Calculates duration from `speed` (pixels/sec) and measured text width. Loops indefinitely. Tap to exit.
- **`lib/screens/home_screen.dart`** — Main input screen. Manages font/color settings via a settings dialog. The text input dynamically resizes based on content, switching to `Expanded` when it hits `_maxInputHeight`. Persists saves via `SharedPreferences`.
- **`lib/screens/saved_screen.dart`** — WIP: currently shows hardcoded items instead of loading from `SharedPreferences`. The `HomeScreen._saveText()` already writes `SavedItem` JSON correctly, but `SavedScreen` does not yet read it.
- **`lib/models/saved_item.dart`** — Data model with `toJson`/`fromJson`. Colors stored as ARGB int values.

### Orientation

The app is locked to landscape via `SystemChrome.setPreferredOrientations` in `main()`. All layout calculations in `HomeScreen` assume landscape dimensions.

### UI Language

UI strings are in Vietnamese (e.g. "Chạy chữ" = run text, "Cài đặt" = settings, "Lưu" = save).
