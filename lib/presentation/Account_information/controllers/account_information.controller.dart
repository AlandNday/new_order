import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Make sure this is used if Google Sign-In is part of your auth flow
import 'package:logger/logger.dart';
import 'package:new_order/domain/core/Models/Profile_model.dart'; // Ensure this path is correct for your Profile model

class AccountInformationController extends GetxController {
  // Firestore and Firebase Auth instances
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Corrected to _firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(); // Keep if needed for sign-out or similar

  // Observable variable for the user's profile
  Rxn<Profile> userProfile =
      Rxn<Profile>(); // Rxn is perfect for nullable Rx objects

  // GetStorage instance for local data caching
  final box = GetStorage();
  static const String profileKey = 'user_profile';

  // Logger instance
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

  // This method now correctly takes the user's UID and updates the userProfile Rxn variable
  Future<void> loadProfileFromFirestore(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore // Use _firestore
              .collection(
                'Users',
              ) // Ensure your collection name is 'Users' (case-sensitive)
              .doc(uid)
              .get();

      if (doc.exists && doc.data() != null) {
        logger.d('Profile data from Firestore: ${doc.data()}');
        // Convert Firestore data to Profile model and update observable
        userProfile.value = Profile.fromJson(doc.data()!, doc.id);
        // Store the raw map data from Firestore to GetStorage
        await box.write(profileKey, doc.data());
        logger.d(
          'Profile loaded and saved to storage: ${userProfile.value?.name}',
        );
      } else {
        // If profile not found in Firestore, clear local storage and observable
        logger.w(
          'Profile not found for UID: $uid. Removing from storage and clearing profile.',
        );
        userProfile.value = null;
        await box.remove(profileKey);
      }
    } catch (e) {
      // Log error and clear profile from storage on error
      logger.e('Error loading profile from Firestore: $e');
      userProfile.value = null;
      await box.remove(profileKey);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Get the current user's UID from Firebase Auth
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Call loadProfileFromFirestore with the current user's UID
      loadProfileFromFirestore(currentUser.uid);
    } else {
      logger.w(
        'No current user logged in. Cannot load profile from Firestore.',
      );
      // Handle cases where no user is logged in, e.g., redirect to login screen
      userProfile.value = null;
      box.remove(profileKey);
    }

    // You might also want to load from GetStorage first for immediate display
    // while Firestore data is being fetched in the background.
    // final storedProfileData = box.read(profileKey);
    // if (storedProfileData != null) {
    //   // Re-create Profile from stored JSON and set it
    //   userProfile.value = Profile.fromJson(storedProfileData, currentUser?.uid ?? 'unknown');
    //   logger.d('Profile loaded from storage: ${userProfile.value?.name}');
    // }
  }

  // You had these as observable strings, but now the Profile model holds the data.
  // You can derive them from userProfile.value
  // RxString userAvatarUrl = ''.obs;
  // RxString userName = ''.obs;

  // You had a 'count' variable and 'get firestore => null;'. These seem like remnants
  // and are not needed for this functionality. Removed for clarity.
  // final count = 0.obs;
  // get firestore => null;
}
