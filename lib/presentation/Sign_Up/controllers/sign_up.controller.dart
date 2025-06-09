import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_order/domain/core/Models/Profile_model.dart';
import 'package:new_order/infrastructure/navigation/routes.dart';

class SignUpController extends GetxController {
  //TODO: Implement SignUpController

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  void signUpWithEmail() async {
    errorMessage.value = ''; // Clear previous errors
    isLoading.value = true;

    // Basic validation
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      errorMessage.value = 'Please fill all fields.';
      isLoading.value = false;
      return;
    }

    if (!GetUtils.isEmail(emailController.text)) {
      errorMessage.value = 'Please enter a valid email address.';
      isLoading.value = false;
      return;
    }

    if (passwordController.text.length < 6) {
      // Firebase usually requires at least 6 characters
      errorMessage.value = 'Password must be at least 6 characters long.';
      isLoading.value = false;
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      errorMessage.value = 'Passwords do not match.';
      isLoading.value = false;
      return;
    }

    try {
      // 1. Create user with email and password using Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Get the UID from the newly created user
      String uid = userCredential.user!.uid;

      // 2. Create a placeholder profile using your Profile model
      final newProfile = Profile(
        id: uid,
        email: emailController.text.trim(),
        name: null, // Placeholder: No name initially
        avatarUrl: null, // Placeholder: No avatar initially
        role: 'Customer', // Default role for new users
        createdAt: DateTime.now(),
      );

      // 3. Save the new profile to Firestore in the 'users' collection
      await _firestore.collection('Users').doc(uid).set(newProfile.toJson());

      // If sign-up and Firestore document creation are successful
      Get.offAllNamed(
        Routes.BOTTOM_NAV_BAR,
      ); // Navigate to your home screen or dashboard
      print('Sign Up successful for user: $uid');
      print('Profile created in Firestore for user: $uid');
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Authentication errors
      if (e.code == 'weak-password') {
        errorMessage.value = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage.value = 'The account already exists for that email.';
      } else {
        errorMessage.value = 'Sign up failed: ${e.message}';
      }
      print('Firebase Auth Error: ${e.message}');
    } catch (e) {
      // Handle any other unexpected errors
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      print('General Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
