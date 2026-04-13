import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  // Singleton so the same instance is always used.
  static final AppSettings _instance = AppSettings._();
  factory AppSettings() => _instance;
  AppSettings._();

  bool _lowDataMode = false;

  bool get lowDataMode => _lowDataMode;

  void setLowDataMode(bool value) {
    if (_lowDataMode == value) return;
    _lowDataMode = value;
    notifyListeners();
  }

  /// Convenience accessor — call AppSettings.of(context) anywhere in the tree.
  static AppSettings of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<_AppSettingsInherited>();
    if (provider == null) {
      throw FlutterError(
        'No AppSettingsProvider found. Wrap your MaterialApp with AppSettingsProvider.',
      );
    }

    return provider.notifier!;
  }
}

// ── InheritedWidget wrapper ───────────────────
class _AppSettingsInherited extends InheritedNotifier<AppSettings> {
  const _AppSettingsInherited({
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);

  @override
  bool updateShouldNotify(_AppSettingsInherited old) =>
      old.notifier != notifier;
}

/// Wrap your MaterialApp (or the root of your widget tree) with this.
class AppSettingsProvider extends StatelessWidget {
  final Widget child;
  const AppSettingsProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return _AppSettingsInherited(settings: AppSettings(), child: child);
  }
}
