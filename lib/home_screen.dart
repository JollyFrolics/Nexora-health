import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/login_screen.dart';
import 'package:patient_app/profile_page.dart';
import 'package:patient_app/widgets/language_toggle_button.dart';
import 'package:patient_app/widgets/login_signup_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controller/internet_status_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  final ConnectivityController controller = Get.put(ConnectivityController());
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
