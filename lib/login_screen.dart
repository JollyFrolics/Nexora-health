import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/controller/internet_status_controller.dart';
import 'package:patient_app/l10n/app_localizations.dart';
import 'package:patient_app/signup_screen.dart';
import 'package:patient_app/widgets/connectivity_icon.dart';
import 'package:patient_app/widgets/input_field.dart';
import 'package:patient_app/widgets/language_toggle_button.dart';
import 'package:patient_app/widgets/login_signup_button.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final ConnectivityController controller = Get.put(ConnectivityController());
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: const Row(
          children: [
            Image(
              image: AssetImage("assets/images/gov_logo.webp"),
              width: 40,
              height: 40,
            ),
            SizedBox(width: 20),
            Column(
              children: [
                Text(
                  AppConstants.nepalSarkar,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  AppConstants.govtOfNepal,
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() {
              if (controller.connectionType.value == ConnectivityResult.none) {
                return ConnectivityIndicator(icon: Icons.signal_wifi_off);
              } else if (controller.connectionType.value ==
                  ConnectivityResult.wifi) {
                return ConnectivityIndicator(icon: Icons.wifi);
              } else if (controller.connectionType.value ==
                  ConnectivityResult.mobile) {
                return ConnectivityIndicator(icon: Icons.signal_cellular_4_bar);
              } else {
                return const SizedBox.shrink();
              }
            }),
          ),
          IconButton(onPressed: () {}, icon: LanguageToggleButton()),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/images/login.json', width: 200, height: 200),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.email,
                    style: const TextStyle(fontSize: 14, color: Colors.black87,fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  InputField(
                    hintText: "ram@gmail.com",
                    obscureText: false,
                    controller: emailcontroller,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.password,
                    style: const TextStyle(fontSize: 14, color: Colors.black87,fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  InputField(
                    hintText: "xxxxxxxx",
                    
                    obscureText: true,
                    controller: passwordcontroller,
                  ),
                ],
              ),
            ),
             LoginSignupButton(text: AppLocalizations.of(context)!.login, onPressed: (){}),
            const SizedBox(height: 20),
             Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text(
                  AppLocalizations.of(context)!.donthaveanaccout,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                TextButton(
                  onPressed:(){
                    Get.offAll(()=>SignupScreen());
                  },
                  child: Text(
                    AppLocalizations.of(context)!.signup,
                    style: const TextStyle(fontSize: 14, color: AppConstants.secondaryColor,fontWeight: FontWeight.bold),
                  ),
                )
              ],
             )
          ],
        ),
      ),
    );
  }
}
