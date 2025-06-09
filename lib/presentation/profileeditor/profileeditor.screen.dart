import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:new_order/presentation/profileeditor/controllers/profileeditor.controller.dart'; // Import for File type to display selected image // Import the updated controller

class ProfileeditorScreen extends GetView<ProfileEditorController> {
  const ProfileeditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is initialized. This is crucial for GetX.
    // If you're routing to this screen via Get.to(() => AccountProfileEditorScreen(), binding: AccountProfileEditorBinding()),
    // then Get.find() would be appropriate. Otherwise, Get.put() ensures it's available.

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Edit Profil Akun',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        // Show loading indicator when fetching profile initially
        if (controller.isLoading.value &&
            controller.userProfile.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error message if fetching profile failed
        if (controller.errorMessage.value.isNotEmpty &&
            controller.userProfile.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () =>
                        controller.fetchUserProfile(), // Retry fetching
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Main content of the editor screen
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Obx(() {
                      final profile = controller.userProfile.value;
                      final String? currentAvatarUrl = profile?.avatarUrl;
                      final File? newSelectedImage =
                          controller.selectedImage.value;

                      Widget avatarWidget;
                      // Prioritize displaying the newly selected image
                      if (newSelectedImage != null) {
                        avatarWidget = Image.file(
                          newSelectedImage,
                          fit: BoxFit.cover,
                        );
                      }
                      // Fallback to cached network image if URL exists
                      else if (currentAvatarUrl != null &&
                          currentAvatarUrl.isNotEmpty) {
                        avatarWidget = CachedNetworkImage(
                          imageUrl: currentAvatarUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: Get.theme.primaryColor,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      }
                      // Default placeholder if no image or URL
                      else {
                        avatarWidget = Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey[600],
                          ),
                        );
                      }

                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: avatarWidget,
                        ),
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: controller
                            .pickImage, // Call the avatar selection method
                        child: Container(
                          decoration: BoxDecoration(
                            color: Get.theme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Nama (Name) Field - Editable
              _buildInfoEditor(
                label: 'Nama',
                controller: controller.nameController,
                hintText: 'Masukkan nama lengkap',
              ),
              const SizedBox(height: 16),

              // Email Field - Read-only (typically tied to authentication)
              _buildInfoEditor(
                label: 'Email',
                controller: controller.emailController,
                hintText: 'Alamat email',
                keyboardType: TextInputType.emailAddress,
                readOnly: true, // Email is typically not editable directly here
              ),
              const SizedBox(height: 40),

              // Save Changes Button
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    // Disable button when loading (saving or fetching)
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: controller.isLoading.value
                        ? CircularProgressIndicator(
                            color: Colors.grey[300],
                          ) // Show progress
                        : Text(
                            'Simpan Perubahan',
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              // Display error message if save fails
              if (controller.errorMessage.value.isNotEmpty &&
                  !controller.isLoading.value)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    controller.errorMessage.value,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  // Helper method for editable info containers (TextFields) - same as before
  Widget _buildInfoEditor({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Get.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: Get.textTheme.bodyLarge?.copyWith(color: Colors.black87),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Get.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Get.theme.primaryColor, // Highlight when focused
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
