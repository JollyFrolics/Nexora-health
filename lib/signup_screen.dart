import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/controller/internet_status_controller.dart';
import 'package:patient_app/home_screen.dart';
import 'package:patient_app/l10n/app_localizations.dart';
import 'package:patient_app/login_screen.dart';
import 'package:patient_app/utils/logging.dart';
import 'package:patient_app/widgets/connectivity_icon.dart';
import 'package:patient_app/widgets/dropdown_inputfield.dart';
import 'package:patient_app/widgets/image_button.dart';
import 'package:patient_app/widgets/input_field.dart';
import 'package:patient_app/widgets/language_toggle_button.dart';
import 'package:patient_app/widgets/loading_overlay.dart';
import 'package:patient_app/widgets/login_signup_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

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

  bool loading = false;

  late TabController tabController;
  final supabase = Supabase.instance.client;
  // Sign up with email and password
  signUp() async {
    // validation for the required fields
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Name is required",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    if (phoneController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Phone is required",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    if (ageController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Age is required",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    if (selectedGender == null) {
      Get.snackbar(
        "Error",
        "Gender is required",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    if (addressController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Address is required",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    if (emailcontroller.text.trim().isEmpty) {
      Get.snackbar('Error', 'Email is required');
      logger('email:"${emailcontroller.text}"', "Nexora signup");
      return;
    }
    if (passwordcontroller.text.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return;
    }
    if (passwordcontroller.text != confirmPasswordController.text) {
      Get.snackbar(
        "Error",
        "Password do not match...",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    // Also validate other fields if needed
    setState(() => loading = true);
    try {
      // setp 1 user authinticate
      final result = await supabase.auth.signUp(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text,
      );
      if (result.user == null) {
        Get.snackbar(
          "Error",
          "Sign up failed",
          colorText: Colors.white,
          backgroundColor: Colors.redAccent,
        );
      }
      // Step 2 :save the user profile
      final userId = result.user!.id;
      await supabase.from("user_profiles").upsert({
        'id': userId,
        'full_name': nameController.text,
        'phone_number': _formatPhone(phoneController.text.trim()),
        'role': 'patient',
        'preferred_language': 'nepali',
        'updated_at': DateTime.now().toIso8601String(),
        'email':emailcontroller.text
      }, onConflict: 'id');

      // step 3 save patient data
      await supabase.from('patients').upsert({
        'user_id': userId,
        'gender': _mapGender(selectedGender),
        'municipality': addressController.text.trim(),
        'date_of_birth': _ageToDateOfBirth(ageController.text.trim()),
      }, onConflict: 'user_id');
      Get.snackbar(
        'सफल! / Success',
        'Account created successfully!',
        backgroundColor: Colors.green.shade100,
        duration: const Duration(seconds: 2),
      );
      await Future.delayed(const Duration(seconds: 2));
      Get.offAll(() => LoginScreen());
    } on AuthException catch (e) {
      // Supabase auth-specific errors (cleaner messages)
      Get.snackbar(
        'Sign Up Failed',
        _authErrorMessage(e.message),
        backgroundColor: Colors.red.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Sign Up Failed',
        e.toString(),
        backgroundColor: Colors.redAccent,
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  continueWithGoogle() async {
    try {
      GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize(
        serverClientId: dotenv.env["web_clientid"],
        clientId: Platform.isAndroid
            ? dotenv.env['android_clientid']
            : dotenv.env["ios_clientid"],
      );
      GoogleSignInAccount account = await signIn.authenticate();
      String idToken = account.authentication.idToken ?? "";
      final authorization =
          await account.authorizationClient.authorizationForScopes([
            "email",
            "profile",
          ]) ??
          await account.authorizationClient.authorizeScopes([
            "email",
            "profile",
          ]);
      final result = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization.accessToken,
      );
      if (result.user == null) {
        return;
      }
      final userId = result.user!.id;
      final googleName =
          result.user!.userMetadata?['full_name'] ??
          result.user!.userMetadata?['name'] ??
          "";
      final googleAvatar = result.user!.userMetadata?['avatar_url'] ?? '';
      // ignore: unused_local_variable
      final googleEmail = result.user!.email ?? '';

      //   save the user_profile ( Google data  + an form data already filled)
      await supabase.from('user_profiles').upsert({
        'id': userId,
        'full_name': nameController.text.trim().isNotEmpty
            ? nameController.text.trim()
            : googleName,
        'phone_number': phoneController.text.trim().isNotEmpty
            ? _formatPhone(phoneController.text.trim())
            : null,
        'role': 'patient',
        'preferred_language': 'nepali',
        'avatar_url': googleAvatar,
        ''
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');

      // save patients row
      final patientData = <String, dynamic>{'user_id': userId};
      if (selectedGender != null) {
        patientData['gender'] = _mapGender(selectedGender);
      }
      if (ageController.text.trim().isNotEmpty) {
        patientData['date_of_birth'] = _ageToDateOfBirth(
          ageController.text.trim(),
        );
      }
      if (addressController.text.trim().isNotEmpty) {
        patientData['municipality'] = addressController.text.trim();
      }
      await supabase
          .from('patients')
          .upsert(patientData, onConflict: 'user_id');
      final hasCompleteProfile =
          nameController.text.trim().isNotEmpty &&
          selectedGender != null &&
          ageController.text.trim().isNotEmpty;

      if (hasCompleteProfile) {
        Get.offAll(() => HomeScreen());
      } else {
        // Profile saved but incomplete → go home anyway,
        // show a banner to complete profile later
        Get.offAll(() => HomeScreen());
        Get.snackbar(
          'प्रोफाइल अपूर्ण',
          'Please complete your profile in settings.',
          backgroundColor: Colors.orange.shade100,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Google Sign-In Failed',
        e.toString(),
        backgroundColor: Colors.red.shade100,
      );
      logger(
        e.toString(),
        "SignupScreen.continueWithGoogle",
        level: Level.info,
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ── HELPER: Convert Nepal phone to E.164 (+977XXXXXXXXXX) ───────────────
  String _formatPhone(String phone) {
    phone = phone.replaceAll(' ', '').replaceAll('-', '');
    if (phone.startsWith('+977')) return phone;
    if (phone.startsWith('977')) return '+$phone';
    if (phone.startsWith('0')) return '+977${phone.substring(1)}';
    return '+977$phone';
  }

  // ── HELPER: Map localized gender string to DB enum value ────────────────
  String _mapGender(String? gender) {
    if (gender == null) return 'other';
    final lower = gender.toLowerCase();
    if (lower.contains('male') || lower == 'पुरुष') return 'male';
    if (lower.contains('female') || lower == 'महिला') return 'female';
    return 'other';
  }

  // ── HELPER: Convert age (int) → approximate date_of_birth string ────────
  String? _ageToDateOfBirth(String ageStr) {
    final age = int.tryParse(ageStr);
    if (age == null) return null;
    final year = DateTime.now().year - age;
    return '$year-01-01'; // Jan 1st of birth year (approximate)
  }

  // ── HELPER: Friendly auth error messages ────────────────────────────────
  String _authErrorMessage(String message) {
    if (message.contains('already registered') ||
        message.contains('User already registered')) {
      return 'This email is already registered. Please login instead.';
    }
    if (message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    return message;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    emailcontroller.dispose();
    passwordcontroller.dispose();
    nameController.dispose();
    phoneController.dispose();
    ageController.dispose();
    genderController.dispose();
    addressController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void sendSignUpData() {
    logger("Sending sign up data", "Nexora Sign up");
    loading = true;
    LoadingOverlay.show(context, widget);

    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        bottom: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppConstants.whiteColor,
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
                                onPressed: () {
                                  Get.offAll(LoginScreen());
                                },
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
                          const SizedBox(height: 10),
                          Text(
                            "or signup with",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ImageButton(
                            imagePath: "assets/images/google.png",
                            text: "Google",
                            onPressed: () {
                              continueWithGoogle();
                            },
                          ),
                          const SizedBox(height: 30),
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
                          text: AppLocalizations.of(context)!.signup,
                          onPressed: (){
                            signUp();
                          },
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (loading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppConstants.primaryColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Creating account...',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
