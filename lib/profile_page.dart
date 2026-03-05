import 'package:flutter/material.dart';
import 'package:patient_app/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.patient)),
      body: const Center(child: Text('This is the profile Screen')),
    );
  }
}
