import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_order/infrastructure/navigation/routes.dart';
import 'controllers/account_information.controller.dart';

class AccountInformationScreen extends GetView<AccountInformationController> {
  const AccountInformationScreen({super.key});
  // Initialize the controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // Subtle shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(), // Navigates back
        ),
        title: Text(
          'Informasi Akun',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false, // Align title to the left as per design
      ),
      body: SingleChildScrollView(
        // Use SingleChildScrollView to prevent overflow on small screens
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar/Profile Picture Placeholder
            Center(
              child: Obx(() {
                // Obx to react to userProfile.value changes
                final profile = controller.userProfile.value;
                final String imageUrl = profile?.avatarUrl ?? '';

                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Light grey background
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ), // Subtle border
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      15.0,
                    ), // Match container's radius
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            // Use CachedNetworkImage for better performance
                            imageUrl,
                            fit: BoxFit.cover, // Fill and crop from center
                          )
                        : Container(
                            // Placeholder if no image URL
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey[600],
                            ),
                          ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30), // Spacing after avatar
            // Nama (Name) Field
            Obx(
              () => _buildInfoDisplay(
                label: 'Nama',
                value: controller.userProfile.value?.name ?? '',
              ),
            ),
            const SizedBox(height: 16),

            // Posisi (Position) Field
            Obx(
              () => controller.userProfile.value?.role == 'admin'
                  ? _buildInfoDisplay(
                      label: 'Posisi',
                      value:
                          controller.userProfile.value?.role ??
                          '', // Assuming 'role' for position
                    )
                  : Container(),
            ),
            const SizedBox(height: 16),

            // Email Field
            Obx(
              () => _buildInfoDisplay(
                label: 'Email',
                value: controller.userProfile.value?.email ?? '',
              ),
            ),
            const SizedBox(height: 16),

            // Nomor HP (Phone Number) Field
            // Obx(() => _buildInfoDisplay(
            //       label: 'Nomor HP',
            //       value: controller.userProfile.value?.phoneNumber ?? '',
            //     )),
            // const SizedBox(height: 16),

            // // Gender Field
            // Obx(() => _buildInfoDisplay(
            //       label: 'Gender',
            //       value: controller.userProfile.value?.gender ?? '',
            //     )),
            const SizedBox(height: 40),

            // Save Changes Button (still present, but fields are display-only)
            // SizedBox(
            //   width: double.infinity, // Occupy full width
            //   child: ElevatedButton(
            //     // Note: Since fields are not directly editable, this button's functionality
            //     // would either trigger a different editing flow or be removed/hidden.
            //     // For now, it remains as per your original request.
            //     onPressed: () {
            //       // Example: Get.snackbar('Info', 'Fields are currently display-only.');
            //       // If you want to enable editing, you'd need a different approach (e.g., an "Edit" button that
            //       // switches to TextField mode, or opens a new screen for editing)
            //       Get.snackbar(
            //         'Information',
            //         'This is a display-only screen. Edits not supported here.',
            //       );
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.black87, // Dark button color
            //       foregroundColor: Colors.white,
            //       padding: const EdgeInsets.symmetric(vertical: 16),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12), // Rounded corners
            //       ),
            //       elevation: 2, // Subtle shadow
            //     ),
            //     child: Text(
            //       'Save changes',
            //       style: Get.textTheme.titleMedium?.copyWith(
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
            ElevatedButton(
              onPressed: () {
                // Assuming your AccountInformationController also has userProfile.value
                Get.toNamed(Routes.PROFILEEDITOR);
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  // --- New helper method for informational display containers ---
  Widget _buildInfoDisplay({
    required String label,
    required String value, // The actual text to display
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
        Container(
          width: double.infinity, // Takes full width
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[100], // Light grey background
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ), // Subtle border
          ),
          child: Text(
            value.isEmpty ? 'N/A' : value, // Display value or 'N/A' if empty
            style: Get.textTheme.bodyLarge?.copyWith(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
