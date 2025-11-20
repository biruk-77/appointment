import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // ✅ Required for Cupertino fallback
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- YOUR IMPORTS ---
import 'core/providers/theme_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/api_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/utils/app_logger.dart';

// --- SCREENS ---
import 'features/splash/splash_screen.dart';
import 'features/auth/auth_wrapper.dart';
import 'features/auth/login_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/orders/orders_screen.dart';
import 'features/payment/payment_history_screen.dart';

// --- LOCALIZATION IMPORT ---
// Use the file you just showed me:
import 'app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.startup('🚀 App Launching...');

  // Initialize Date Formatting
  await Future.wait([
    initializeDateFormatting('en', null),
    initializeDateFormatting('am', null),
    initializeDateFormatting('so', null),
  ]);

  runApp(const GoHospitalApp());
}

class GoHospitalApp extends StatelessWidget {
  const GoHospitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ApiProvider.instance),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'Go Hospital',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,

            // 1. Set Locale
            locale: languageProvider.currentLocale,

            // 2. Supported Languages
            supportedLocales: const [Locale('en'), Locale('am'), Locale('so')],

            // 3. REGISTER DELEGATES (Crucial Step!)
            localizationsDelegates: const [
              // A. Your Generated App Translations
              AppLocalizations.delegate,

              // B. Standard Flutter Delegates
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,

              // C. 🔥 THE FIX: Custom Somali Fallbacks 🔥
              // This prevents the "No MaterialLocalizations found" crash
              SomaliMaterialLocalizationsDelegate(),
              SomaliCupertinoLocalizationsDelegate(),
            ],

            home: const AppInitializer(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/orders': (context) => const OrdersScreen(),
              '/payment-history': (context) => const PaymentHistoryScreen(),
            },
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<LanguageProvider>(context, listen: false).initialize();
      await Provider.of<ApiProvider>(context, listen: false).initialize();
      await Provider.of<AuthProvider>(context, listen: false).initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }
    return const AuthWrapper();
  }
}

// ============================================================================
// 🔥 COPY THIS BOTTOM PART EXACTLY - DO NOT DELETE 🔥
// ============================================================================

/// This class tricks Flutter into using English system text (Copy, Paste, etc.)
/// when the phone language is set to Somali, because Flutter has no built-in Somali support.
class SomaliMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const SomaliMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'so';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return const DefaultMaterialLocalizations();
  }

  @override
  bool shouldReload(SomaliMaterialLocalizationsDelegate old) => false;
}

class SomaliCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const SomaliCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'so';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return const DefaultCupertinoLocalizations();
  }

  @override
  bool shouldReload(SomaliCupertinoLocalizationsDelegate old) => false;
}
