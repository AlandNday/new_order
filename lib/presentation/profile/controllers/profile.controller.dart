import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:new_order/domain/core/Models/Profile_model.dart';
import 'package:new_order/infrastructure/navigation/routes.dart';

class ProfileController extends GetxController {
  //TODO: Implement ProfileController
  Rxn<Profile> userProfile = Rxn<Profile>();
  RxString userAvatarUrl = ''.obs; // To store the passed avatar URL
  RxString userName = ''.obs;
  final box = GetStorage();
  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    Map<String, dynamic>? storedProfileJson = box.read('user_profile');
    if (storedProfileJson != null) {
      print('User profile map from GetStorage: $storedProfileJson');
      // Convert the map to your Profile model and assign it to the Rxn variable
      // Ensure 'id' is part of your Profile.fromJson or handle it appropriately
      userProfile.value = Profile.fromJson(
        storedProfileJson,
        storedProfileJson['id'] ?? 'unknown_id',
      );
      print('User role from Profile model: ${userProfile.value?.role}');

      // You can also update your separate RxString variables if you prefer
      userName.value = userProfile.value?.name ?? '';
      userAvatarUrl.value = userProfile.value?.avatarUrl ?? '';
    } else {
      print('User profile not found in GetStorage.');
      userProfile.value = null; // Ensure it's null if not found
    }
  }

  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  final TextEditingController nameController = TextEditingController();
  final TextEditingController positionController =
      TextEditingController(); // For 'Posisi'
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController =
      TextEditingController(); // For 'Nomor HP'
  final TextEditingController genderController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
  Future<void> logout() async {
    try {
      // Show a loading indicator if you like
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // 1. Sign out from Firebase Authentication
      await FirebaseAuth.instance.signOut();
      print("Firebase signed out successfully.");

      // 2. Sign out from Google Sign-In (CRUCIAL if user logged in with Google)
      // This clears the Google session from the device.
      if (await GoogleSignIn().isSignedIn()) {
        await GoogleSignIn().signOut();
        print("Google signed out successfully.");
      }

      // Close the loading indicator
      Get.offAllNamed(Routes.LOG_IN); //

      // IMPORTANT: Your AuthController or main.dart's AuthGate (StreamBuilder)
      // will automatically detect this signOut and navigate back to the login screen.
      // You typically DO NOT call Get.offAllNamed(Routes.LOGIN) here,
      // as it's the responsibility of the top-level auth state listener.

      Get.snackbar(
        'Success',
        'You have been logged out.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.offAllNamed(Routes.LOG_IN); // Dismiss loading indicator on error
      print("Error during logout: $e");
      Get.snackbar(
        'Error',
        'Failed to log out: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
