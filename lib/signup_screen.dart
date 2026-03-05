import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/controller/internet_status_controller.dart';
import 'package:patient_app/l10n/app_localizations.dart';
import 'package:patient_app/widgets/connectivity_icon.dart';
import 'package:patient_app/widgets/dropdown_inputfield.dart';
import 'package:patient_app/widgets/input_field.dart';
import 'package:patient_app/widgets/language_toggle_button.dart';
import 'package:patient_app/widgets/login_signup_button.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final ConnectivityController controller = Get.put(ConnectivityController());

  final emailcontroller = TextEditingController();

  final passwordcontroller = TextEditingController();

  final nameController = TextEditingController();

  final phoneController = TextEditingController();

  final ageController = TextEditingController();

  final genderController = TextEditingController();

  final addressController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  String? selectedGender;

  late TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(text: "Personal Info"),
            Tab(text: "Account Info"),
          ],
        ),
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
        iconTheme: const IconThemeData(color: Colors.white),
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
      body: TabBarView(
        controller: tabController,
        children: [
          // Tab 1: Personal Info
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SingleChildScrollView(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                InputField(
                                  hintText: "Ram Bahadur",
                                  obscureText: false,
                                  controller: nameController,
                                ),
                                const SizedBox(height: 20),

                                Text(
                                  AppLocalizations.of(context)!.phone,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                InputField(
                                  hintText: "98xxxxxxx",
                                  obscureText: false,
                                  controller: phoneController,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  AppLocalizations.of(context)!.age,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                InputField(
                                  hintText: "24",
                                  obscureText: false,
                                  controller: ageController,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  AppLocalizations.of(context)!.gender,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                DropdownInputField(
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.gender,
                                  items: <String>[
                                    AppLocalizations.of(context)!.male,
                                    AppLocalizations.of(context)!.female,
                                    AppLocalizations.of(context)!.others,
                                  ],
                                  onChanged: (value) {
                                    selectedGender = value;
                                  },
                                  value: selectedGender,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  AppLocalizations.of(context)!.address,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                InputField(
                                  hintText: "Kathmandu-4, Nepal",
                                  obscureText: false,
                                  controller: addressController,
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                          LoginSignupButton(
                            text: AppLocalizations.of(context)!.next,
                            onPressed: () {
                              tabController.animateTo(1); // move to tab 2
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.alreadyhaveanaccount,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  AppLocalizations.of(context)!.login,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppConstants.secondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     tabController.animateTo(1); // move to tab 2
                          //   },
                          //   child: const Text("Next"),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tab 2: Account Info
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
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
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              InputField(
                                hintText: "xxxxxxxx",
                                obscureText: true,
                                controller: passwordcontroller,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                AppLocalizations.of(context)!.confirmpassword,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              InputField(
                                hintText: "xxxxxxxxx",
                                obscureText: true,
                                controller: confirmPasswordController,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                        LoginSignupButton(
                          text: AppLocalizations.of(context)!.back,
                          onPressed: () {
                            tabController.animateTo(0); // move to tab 1
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
