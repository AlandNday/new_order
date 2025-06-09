import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:new_order/domain/core/Models/Profile_model.dart'; // Ensure this path is correct
import 'package:new_order/infrastructure/navigation/routes.dart';
import 'package:get_storage/get_storage.dart'; // Import GetStorage

class LogInController extends GetxController {
  // Text editing controllers for login fields
  final TextEditingController EmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Firestore and Auth instances
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Observable variables for UI state and data
  RxBool isPasswordHidden = true.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Rxn for nullable Profile model to hold the current user's profile
  final Rxn<Profile> currentProfile = Rxn<Profile>();

  // GetStorage instance for local data persistence
  final box = GetStorage();
  static const String profileKey =
      'user_profile'; // Key for storing profile data in GetStorage

  // Logger for better debugging output
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

  // --- Helper function to handle successful authentication across different login methods ---
  Future<void> _handleSuccessfulAuth(User user) async {
    logger.d('User signed in: ${user.uid}');

    // 1. Attempt to load profile from GetStorage first for immediate UI update.
    // This provides a quicker response if the profile is already cached locally.
    loadProfileFromStorage(user.uid);

    // 2. Fetch the latest profile from Firestore to ensure data freshness.
    // This also updates the profile in GetStorage.
    await loadProfileFromFirestore(user.uid);

    // After loading/fetching, determine the initial route based on the user's role.
    // Ensure currentProfile.value is not null before accessing its properties.
    final Map<String, dynamic> args = {
      'avatarUrl': currentProfile.value?.avatarUrl,
      'name': currentProfile.value?.name,
    };

    logger.d('User role: ${currentProfile.value?.role}');
    if (currentProfile.value?.role == "admin") {
      Get.offAllNamed(
        Routes.ADMINNAVBAR,
        arguments: args,
      ); // Navigate to admin dashboard
    } else {
      Get.offAllNamed(
        Routes.BOTTOM_NAV_BAR,
        arguments: args,
      ); // Navigate to regular user dashboard
    }

    // Show success snackbar
    Get.snackbar(
      'Login Berhasil',
      'Anda berhasil masuk!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          Get.theme.colorScheme.primary, // Using theme colors for better design
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  // --- Fetches user profile from Firestore and stores it in GetStorage ---
  Future<void> loadProfileFromFirestore(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await firestore
          .collection('Users')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        logger.d('Profile data from Firestore: ${doc.data()}');
        // Convert Firestore data to Profile model and update observable
        currentProfile.value = Profile.fromJson(doc.data()!, doc.id);
        // Store the raw map data from Firestore to GetStorage
        await box.write(profileKey, doc.data());
        logger.d('Profile saved to storage: ${currentProfile.value}');
      } else {
        // If profile not found in Firestore, clear local storage and observable
        logger.w('Profile not found for UID: $uid. Removing from storage.');
        currentProfile.value = null;
        await box.remove(profileKey);
      }
    } catch (e) {
      // Log error and clear profile from storage on error
      logger.e('Error loading profile from Firestore: $e');
      currentProfile.value = null;
      await box.remove(profileKey);
    }
  }

  // --- Loads user profile from GetStorage ---
  void loadProfileFromStorage(String uid) {
    // Read the stored profile data as a Map
    final storedProfileJson = box.read<Map<String, dynamic>>(profileKey);
    if (storedProfileJson != null) {
      // If data exists, convert it to Profile model and update observable
      // Use uid as fallback for id if not explicitly in stored json
      currentProfile.value = Profile.fromJson(
        storedProfileJson,
        storedProfileJson['id'] ?? uid, // Use stored 'id' or fallback to uid
      );
      logger.d('Profile loaded from storage: ${currentProfile.value}');
    } else {
      logger.d('No profile found in storage for UID: $uid.');
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Listen to Firebase authentication state changes.
    // This is useful for handling automatic logins/logouts if the app restarts
    // or the user's auth state changes externally.
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // If user is logged in, try to load profile from storage immediately.
        // A full Firestore refresh might be triggered elsewhere (e.g., on specific pages).
        loadProfileFromStorage(user.uid);
      } else {
        // If user logs out, clear the current profile and local storage.
        currentProfile.value = null;
        box.remove(profileKey);
      }
    });
  }

  // --- Toggle password visibility in login form ---
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // --- Handles email and password sign-in ---
  Future<void> signInWithEmail() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (EmailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty) {
        final UserCredential userCredential = await _auth
            .signInWithEmailAndPassword(
              email: EmailController.text,
              password: passwordController.text,
            );
        if (userCredential.user != null) {
          // Call the central handler for successful authentication
          await _handleSuccessfulAuth(userCredential.user!);
        } else {
          // This case is unlikely with Firebase signInWithEmailAndPassword,
          // as it usually throws an exception if user is null.
          Get.snackbar('Login Gagal', 'User data not found after sign-in.');
        }
      } else {
        Get.snackbar('Login Gagal', 'Email atau password harus diisi.');
      }
    } on FirebaseAuthException catch (e) {
      // Catch specific Firebase authentication errors
      errorMessage.value =
          e.message ?? 'Terjadi kesalahan tidak diketahui saat masuk.';
      logger.e('Firebase Auth Error: ${e.code} - ${e.message}');
      Get.snackbar('Login Gagal', errorMessage.value);
    } catch (e) {
      // Catch any other unexpected errors
      errorMessage.value = 'Terjadi kesalahan yang tidak terduga.';
      logger.e('Error: $e');
      Get.snackbar('Login Gagal', errorMessage.value);
    } finally {
      isLoading.value = false; // Always set loading to false
    }
  }

  // --- Handles email and password sign-up ---
  Future<void> signUpWithEmail() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (EmailController.text.isEmpty || passwordController.text.isEmpty) {
        Get.snackbar('Daftar Gagal', 'Email dan password harus diisi.');
        isLoading.value = false;
        return;
      }
      await _auth.createUserWithEmailAndPassword(
        email: EmailController.text,
        password: passwordController.text,
      );
      Get.snackbar('Berhasil', 'Akun berhasil dibuat! Silakan masuk.');
      // Optionally, you might want to automatically sign in after signup
      // and call _handleSuccessfulAuth, or navigate to login page.
    } on FirebaseAuthException catch (e) {
      errorMessage.value =
          e.message ?? 'Terjadi kesalahan tidak diketahui saat mendaftar.';
      logger.e('Firebase Auth Error: ${e.code} - ${e.message}');
      Get.snackbar('Daftar Gagal', errorMessage.value);
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan yang tidak terduga.';
      logger.e('Error: $e');
      Get.snackbar('Daftar Gagal', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // --- Handles Google Sign-in ---
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        isLoading.value = false;
        return; // User cancelled the sign-in process
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        final User user = userCredential.user!;
        final DocumentReference userDoc = firestore
            .collection('Users')
            .doc(user.uid);
        final DocumentSnapshot doc = await userDoc.get();

        if (!doc.exists) {
          // Create a new user profile in Firestore
          final newProfile = Profile(
            id: user.uid,
            email: user.email ?? '',
            name: user.displayName,
            avatarUrl: user.photoURL,
            role: 'normal', // Default role
            createdAt: DateTime.now(),
          );
          await userDoc.set(newProfile.toJson());
          logger.d('New profile created for user: ${user.uid}');
        }

        // Call the central handler for successful authentication
        await _handleSuccessfulAuth(user);
      } else {
        Get.snackbar(
          'Login Gagal',
          'Data pengguna Google tidak ditemukan setelah masuk.',
        );
      }
    } on FirebaseAuthException catch (e) {
      errorMessage.value =
          e.message ??
          'Terjadi kesalahan tidak diketahui saat masuk dengan Google.';
      logger.e('Firebase Auth Error: ${e.code} - ${e.message}');
      Get.snackbar('Login Gagal', errorMessage.value);
    } catch (e) {
      errorMessage.value =
          'Terjadi kesalahan yang tidak terduga saat masuk dengan Google.';
      logger.e('Error: $e');
      Get.snackbar('Login Gagal', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Clean up controllers when the controller is closed
    EmailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
