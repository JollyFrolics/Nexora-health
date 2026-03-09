import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/l10n/app_localizations.dart';
import 'package:patient_app/login_screen.dart';
import 'package:patient_app/profile_page.dart';
import 'package:patient_app/widgets/language_toggle_button.dart';
import 'package:patient_app/widgets/login_signup_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.secondaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.homeScreen,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
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
            LanguageToggleButton(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.to(() => const ProfileScreen());
              },
              child: const Text('Go to Profile'),
            ),
            LoginSignupButton(
              text: "Logout",
              onPressed: () async {
                await supabase.auth.signOut();
               Get.offAll(()=>LoginScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}
