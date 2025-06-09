import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Import for Get.snackbar colors if not already
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:new_order/domain/core/Models/Announcement_model.dart';
import 'package:new_order/domain/core/Models/Profile_model.dart';
import 'package:get_storage/get_storage.dart';

class BottomNavBarController extends GetxController {
  final TextEditingController EmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  RxBool isPasswordHidden = true.obs;
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
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  final currentProfile = Rxn<Profile>();
  final box = GetStorage();
  static const String profileKey = 'user_profile';
  String? getUid() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      // User is not logged in
      return null;
    }
  }

  Future<void> loadProfileFromFirestore(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await firestore
          .collection('Users')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        logger.d('Profile data from Firestore: ${doc.data()}');
        currentProfile.value = Profile.fromJson(doc.data()!, doc.id);
        await box.write(profileKey, doc.data());
        logger.d('Profile saved to storage: ${currentProfile.value}');
      } else {
        print('Profile not found for UID: $uid. Removing from storage.');
        currentProfile.value = null;
        await box.remove(profileKey);
      }
    } catch (e) {
      print('Error loading profile from Firestore: $e');
      currentProfile.value = null;
      await box.remove(profileKey);
      rethrow; // Re-throw to be caught by the calling function (e.g., reloadProfile)
    }
  }

  //TODO: Implement BottomNavBarController
  final RxInt currentIndex = 0.obs;

  // List of all the screens for your tabs
  final List<String> pageTitles = ['Home', 'Explore', 'Favorites', 'Profile'];

  void changePage(int index) {
    currentIndex.value = index;
    // You can add logic here for specific tab changes,
    // like resetting scroll position, fetching data, etc.
  }

  final count = 0.obs;

  get announcements => null;
  @override
  void onInit() async {
    super.onInit();
    String? uid = getUid();

    logger.d(currentProfile.value?.avatarUrl ?? '');
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
