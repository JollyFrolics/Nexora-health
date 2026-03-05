import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/route_manager.dart';
import 'package:patient_app/splash_screen.dart';
import 'package:patient_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String languageCode = prefs.getString("language") ?? "en";

  runApp(PatientApp(languageCode: languageCode));
}

class PatientApp extends StatefulWidget {
  final String languageCode;

  const PatientApp({super.key, required this.languageCode});

  static _PatientAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_PatientAppState>();

  @override
  State<PatientApp> createState() => _PatientAppState();
}

class _PatientAppState extends State<PatientApp> {
  String get currentLanguageCode => _locale.languageCode;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.languageCode);
  }

  void changeLanguage(String code) async {
    Locale newLocale = Locale(code);
    setState(() {
      _locale = Locale(code);
    });
    Get.updateLocale(newLocale);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", code);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ne')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
