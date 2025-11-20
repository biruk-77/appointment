# Localization Guide - Go Hospital App

## Overview
The Go Hospital app supports **English (en)** and **Amharic (am)** localization using Flutter's built-in localization system.

## Files Structure
```
lib/
├── app_en.arb                          # English strings
├── app_am.arb                          # Amharic strings
├── app_localizations.dart              # Generated (auto)
├── app_localizations_en.dart           # Generated (auto)
├── app_localizations_am.dart           # Generated (auto)
├── core/
│   ├── providers/
│   │   └── language_provider.dart       # Language switching logic
│   └── extensions/
│       └── localization_extension.dart  # Easy access helper
└── main.dart                           # App setup with localization
```

## Using Localization in Widgets

### Method 1: Using Extension (Recommended)
```dart
import 'package:Go Hospital/core/extensions/localization_extension.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(context.l10n.appTitle);  // Easy access!
  }
}
```

### Method 2: Using AppLocalizations Directly
```dart
import 'package:Go Hospital/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(l10n.appTitle);
  }
}
```

## Switching Languages

### From Any Widget
```dart
import 'package:provider/provider.dart';
import 'package:Go Hospital/core/providers/language_provider.dart';

// Toggle between English and Amharic
context.read<LanguageProvider>().toggleLanguage();

// Set specific language
context.read<LanguageProvider>().setLanguage('am');  // Amharic
context.read<LanguageProvider>().setLanguage('en');  // English
```

### Check Current Language
```dart
final languageProvider = context.read<LanguageProvider>();

if (languageProvider.isEnglish) {
  // Do something for English
}

if (languageProvider.isAmharic) {
  // Do something for Amharic
}

String code = languageProvider.languageCode;  // 'en' or 'am'
```

## Adding New Strings

### 1. Add to English ARB file (`app_en.arb`)
```json
{
  "myNewString": "This is my new string",
  "anotherString": "Another translation"
}
```

### 2. Add to Amharic ARB file (`app_am.arb`)
```json
{
  "myNewString": "ይህ አዲስ ሕብረቁምፊ ነው",
  "anotherString": "ሌላ ትርጉም"
}
```

### 3. Generate Localization Files
```bash
flutter gen-l10n
```

### 4. Use in Code
```dart
context.l10n.myNewString
```

## Localization Configuration

The localization is configured in `l10n.yaml`:
```yaml
arb-dir: lib
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

## Supported Locales
- **English**: `Locale('en')`
- **Amharic**: `Locale('am')`

## Language Persistence
The selected language is automatically saved to SharedPreferences and restored on app restart.

## Example: Language Switcher Widget
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Go Hospital/core/providers/language_provider.dart';
import 'package:Go Hospital/core/extensions/localization_extension.dart';

class LanguageSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return PopupMenuButton<String>(
          onSelected: (value) {
            languageProvider.setLanguage(value);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'en',
              child: Text('English'),
            ),
            PopupMenuItem(
              value: 'am',
              child: Text('አማርኛ'),
            ),
          ],
          child: Text(context.l10n.language),
        );
      },
    );
  }
}
```

## Best Practices
1. ✅ Always use `context.l10n.stringKey` for easy access
2. ✅ Keep translations consistent between English and Amharic
3. ✅ Test both languages before committing
4. ✅ Use meaningful key names (e.g., `loginButtonLabel` not `btn1`)
5. ✅ Run `flutter gen-l10n` after modifying ARB files
6. ✅ Never hardcode strings - always use localization

## Troubleshooting

### Strings not updating after adding new ones?
```bash
flutter clean
flutter pub get
flutter gen-l10n
```

### Language not changing?
- Ensure `LanguageProvider` is initialized in `main.dart`
- Check that `Consumer2<ThemeProvider, LanguageProvider>` is used in MaterialApp
- Verify SharedPreferences is working

### Generated files not found?
- Run `flutter gen-l10n` from project root
- Check `l10n.yaml` configuration
- Ensure ARB files are in `lib/` directory
