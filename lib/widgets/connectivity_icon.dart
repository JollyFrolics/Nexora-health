import 'package:flutter/material.dart';
import 'package:patient_app/app_constants.dart';

class ConnectivityIndicator extends StatelessWidget {
  final IconData icon;
  const ConnectivityIndicator({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: AppConstants.whiteColor, size: 20),
    );
  }
}
