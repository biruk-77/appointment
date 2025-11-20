// File: lib/core/extensions/localization_extension.dart

import 'package:flutter/material.dart';
import '../../app_localizations.dart';

/// Extension on BuildContext to simplify localization access
extension LocalizationExtension on BuildContext {
  /// Easier access to AppLocalizations
  /// Usage: context.l10n.someString
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
