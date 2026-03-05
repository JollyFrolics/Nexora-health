import 'package:flutter/material.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/main.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLang = PatientApp.of(context)?.currentLanguageCode;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(25),
        borderWidth: 0,
        constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
        selectedColor: AppConstants.primaryColor,
        fillColor: Colors.white,
        color: Colors.white,
        isSelected: [currentLang == 'en', currentLang == 'ne'],
        onPressed: (index) {
          if (index == 0) {
            PatientApp.of(context)?.changeLanguage('en');
          } else {
            PatientApp.of(context)?.changeLanguage('ne');
          }
        },
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'En',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "ने",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
