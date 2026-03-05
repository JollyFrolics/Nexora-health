import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_app/l10n/app_localizations.dart';
import 'package:patient_app/main.dart';
import 'package:patient_app/profile_page.dart';
import 'package:patient_app/widgets/language_toggle_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.homeScreen),
        automaticallyImplyLeading:
            false, // Prevents a back button on the Home Screen
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.login,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 20),
            LanguageToggleButton( ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.to(()=>const ProfileScreen());
              },
              child: const Text('Go to Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
