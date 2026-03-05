


import 'package:flutter/material.dart';
import 'package:patient_app/main.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
  isSelected:[
    PatientApp.of(context)?.currentLanguageCode == 'en' ,
    PatientApp.of(context)?.currentLanguageCode == 'ne' ,
  ],
  onPressed: (index){
    if(index == 0){
      PatientApp.of(context)?.changeLanguage('en');
    }else{
      PatientApp.of(context)?.changeLanguage('ne');
    }
  },
children:const[
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text('English'),
    ),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text('Nepali'),
    ),
  ]
);
  }
}