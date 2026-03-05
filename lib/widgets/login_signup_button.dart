import 'package:flutter/material.dart';
import 'package:patient_app/app_constants.dart';

class LoginSignupButton extends StatelessWidget {
  const LoginSignupButton({
    super.key,
    required this.text,
    required this.onPressed,
  });
  final String text;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 100),
      child: ElevatedButton(onPressed: onPressed,style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text(text,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),)));
  }
}
