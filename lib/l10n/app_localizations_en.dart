// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Telemedical App';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get bookAppointment => 'Book Appointment';

  @override
  String get doctor => 'Doctor';

  @override
  String get patient => 'Patient';
}
