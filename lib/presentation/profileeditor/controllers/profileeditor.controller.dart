import 'dart:convert'; // For JSON decoding
import 'dart:io'; // For File type

import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Auth (to get UID)
import 'package:flutter/material.dart'; // For SnackBar and TextEditingController
import 'package:get/get.dart'; // For GetX functionalities
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:http/http.dart' as http;
import 'package:new_order/infrastructure/navigation/routes.dart'; // For making HTTP requests to Cloudinary

// Your provided Profile Model
class Profile {
  final String id; // This will typically be the Firebase Auth UID
  final String email;
  final String? name;
  final String? avatarUrl;
  final String role; // <--- This is now a String
  final DateTime? createdAt;

  Profile({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.role,
    this.createdAt,
  });

  // Factory constructor to create a Profile instance from a JSON map (e.g., from Firestore)
  factory Profile.fromJson(Map<String, dynamic> json, String id) {
    return Profile(
      id: id,
      email: json['email'] ?? '',
      name: json['name'],
      avatarUrl: json['avatarurl'], // Corrected key to match Firestore
      role: json['role'] as String? ?? 'normal',
      createdAt:
          (json['createdAt'] is Timestamp) // Handle Timestamp from Firestore
          ? (json['createdAt'] as Timestamp).toDate()
          : (json['createdAt'] != null &&
                    json['createdAt']
                        is String // Fallback for string date if necessary
                ? DateTime.parse(json['createdAt'] as String)
                : null),
    );
  }

  // Converts the Profile instance to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'avatarurl': avatarUrl,
      'role': role,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : null, // Store as Firestore Timestamp
    };
  }

  // A copyWith method for easier updating of specific fields
  Profile copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? role,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ProfileEditorController extends GetxController {
  // Firestore and Auth instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Rx variables for reactive state
  final Rx<Profile?> userProfile = Rx<Profile?>(
    null,
  ); // Holds the current user profile
  final Rx<File?> selectedImage = Rx<File?>(
    null,
  ); // Holds the image selected for upload
  final RxString errorMessage =
      ''.obs; // For displaying error messages to the user
  final RxBool isLoading = false.obs; // To show loading indicators

  // Cloudinary credentials (REPLACE WITH YOUR ACTUAL VALUES)
  // For production, consider using environment variables or a secure configuration
  final String _cloudinaryCloudName =
      'dh1btqzox'; // Replace with your Cloudinary Cloud Name
  final String _cloudinaryUploadPreset =
      'NewOrder'; // Replace with your Cloudinary Upload Preset
  static const String profileKey = 'user_profile';
  // Text editing controllers for editable fields
  late TextEditingController nameController;
  late TextEditingController roleController;
  late TextEditingController emailController;
  // Note: Your provided Profile model does not include phoneNumber or gender.
  // If you need them, add them to your Profile class first.
  final box = GetStorage();
  @override
  void onInit() {
    super.onInit();
    // Initialize text controllers
    nameController = TextEditingController();
    roleController = TextEditingController();
    emailController = TextEditingController();

    // Fetch user profile data when the controller initializes
    fetchUserProfile();
  }

  // Fetches the user profile from Firestore
  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    errorMessage.value = ''; // Clear any previous errors

    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'User not logged in.';
        isLoading.value = false;
        return;
      }

      // Fetch the document from the 'users' collection using the user's UID
      final docSnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        // Create Profile object from Firestore data
        userProfile.value = Profile.fromJson(
          docSnapshot.data()!,
          docSnapshot.id,
        );
        await box.write(profileKey, docSnapshot.data());
        _populateControllers(userProfile.value!); // Populate text fields
      } else {
        errorMessage.value =
            'User profile not found in Firestore. Creating default profile.';
        // If profile doesn't exist, create a new one with basic info
        final newProfile = Profile(
          id: user.uid,
          email: user.email ?? 'no-email@example.com',
          name: user.displayName, // Use Firebase Auth display name as default
          role: 'normal',
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection('Users')
            .doc(user.uid)
            .set(newProfile.toJson());
        userProfile.value = newProfile;
        _populateControllers(newProfile);
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch user profile: $e';
      print('Error fetching user profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Populates the text controllers with the current profile data
  void _populateControllers(Profile profile) {
    nameController.text = profile.name ?? '';
    roleController.text = profile.role; // role is non-nullable
    emailController.text = profile.email; // email is non-nullable
  }

  // --- Your provided image pick logic ---
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  // --- Your provided image upload logic to Cloudinary ---
  Future<String?> _uploadImageToCloudinary() async {
    if (selectedImage.value == null) {
      print('No image selected for Cloudinary upload.');
      return null;
    }

    try {
      final uploadUrl = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', uploadUrl)
        ..fields['upload_preset'] = _cloudinaryUploadPreset
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            selectedImage.value!.path,
            filename: selectedImage.value!.path.split('/').last,
          ),
        );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        final secureUrl = data['secure_url'] as String?;
        if (secureUrl != null) {
          print('Image uploaded to Cloudinary successfully: $secureUrl');
          return secureUrl;
        } else {
          print(
            'Cloudinary response did not contain a secure_url: $responseData',
          );
          errorMessage.value =
              'Cloudinary upload failed: secure URL not found.';
          return null;
        }
      } else {
        final errorBody = await response.stream.bytesToString();
        print(
          'Cloudinary upload failed! Status: ${response.statusCode}, Error: $errorBody',
        );
        errorMessage.value =
            'Image upload failed. Cloudinary error: ${response.statusCode}';
        return null;
      }
    } catch (e) {
      print('An error occurred during Cloudinary upload: $e');
      errorMessage.value = 'Error uploading image: $e';
      return null;
    }
  }

  // Saves the updated profile data to Firestore
  Future<void> saveProfile() async {
    isLoading.value = true;
    errorMessage.value = ''; // Clear previous errors

    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'User not logged in.';
        isLoading.value = false;
        return;
      }

      String? newAvatarUrl =
          userProfile.value?.avatarUrl; // Start with existing avatar URL

      // 1. Upload new image if one is selected
      if (selectedImage.value != null) {
        final uploadedUrl = await _uploadImageToCloudinary();
        if (uploadedUrl == null) {
          // If upload fails, stop the save process and keep the error message
          isLoading.value = false;
          return;
        }
        newAvatarUrl =
            uploadedUrl; // Update avatar URL with the newly uploaded one
      }

      // 2. Prepare updated data for Firestore
      final updatedData = {
        'name': nameController.text.isEmpty
            ? null
            : nameController.text, // Store null if name is empty
        'role': roleController.text,
        // Email is usually handled by Firebase Auth directly, not updated via profile
        // 'email': emailController.text, // Keep this commented out if email is read-only
        'avatarurl': newAvatarUrl,
      };

      // 3. Update the Firestore document
      await _firestore.collection('Users').doc(user.uid).update(updatedData);
      fetchUserProfile();
      await box.write(profileKey, userProfile.value!);
      // 4. Update the local Rx variable to reflect changes immediately in UI
      userProfile.value = userProfile.value?.copyWith(
        name: nameController.text,
        role: roleController.text,
        avatarUrl: newAvatarUrl,
        // email: emailController.text, // Keep commented out if email is read-only
      );
      Get.back();
      selectedImage.value = null; // Clear selected image after successful save
      Get.snackbar(
        'Success',
        'Profile updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offNamed(Routes.ACCOUNT_INFORMATION);
    } catch (e) {
      errorMessage.value = 'Failed to save profile: $e';
      print('Error saving profile: $e');
      Get.snackbar(
        'Error',
        'Failed to save profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose of text controllers to prevent memory leaks
    nameController.dispose();
    roleController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
