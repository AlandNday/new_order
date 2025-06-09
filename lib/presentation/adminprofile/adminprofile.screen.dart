import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_order/domain/core/Models/Profile_model.dart';
import 'package:new_order/infrastructure/navigation/routes.dart';
import 'package:new_order/presentation/adminprofile/controllers/adminprofile.controller.dart';

class AdminprofileScreen extends GetView<AdminprofileController> {
  const AdminprofileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Register the controller if it's not already registered in your bindings
    // For simple cases, Get.put() can be called directly in build for quick testing,
    // but typically you'd bind it in GetPage or via a separate binding class.

    return Scaffold(
      backgroundColor:
          Colors.white, // Set background to white to match the image
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 30.0,
        ), // Adjusted padding
        child: Column(
          children: [
            // Centered Profile Picture Placeholder
            Center(
              child: Container(
                width: 120, // Adjusted width
                height: 120, // Adjusted height
                decoration: BoxDecoration(
                  color:
                      Colors.grey[200], // Light grey background for placeholder
                  borderRadius: BorderRadius.circular(
                    15.0,
                  ), // Slightly rounded corners
                ),
                // Use ClipRRect to ensure the image respects the rounded corners of the container
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    15.0,
                  ), // Match the container's radius
                  child: Image.network(
                    controller.userProfile.value?.avatarUrl ?? '',
                    fit: BoxFit
                        .cover, // Makes the image fill the frame and crop from the center
                    // Basic error handling: if image fails, show a gray background with a person icon
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300], // Placeholder color
                        child: const Icon(
                          Icons.person, // Simple icon
                          size: 80,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 50), // Increased spacing below profile picture
            // List of button-like containers for profile options
            const SizedBox(height: 10), // Reduced spacing between tiles
            _ProfileOptionTile(
              icon: Icons.account_circle, // Account icon for account info
              title: 'Informasi Akun', // "Informasi Akun" (Account Information)
              onTap: () {
                print('Informasi Akun tapped');
                Get.toNamed(Routes.ACCOUNT_INFORMATION);
                // You would navigate to the account information screen here
                // Get.toNamed('/account_info');
              },
            ),
            const SizedBox(height: 10), // Reduced spacing between tiles
            _ProfileOptionTile(
              icon: Icons.help_outline, // Help icon
              title: 'Help', // Changed from 'Bantuan' to 'Help' as per image
              onTap: () {
                print('Help tapped');
                // You would navigate to a help/support screen here
                // Get.toNamed('/help');
              },
            ),
            const SizedBox(height: 10), // Reduced spacing between tiles
            _ProfileOptionTile(
              icon: Icons.logout, // Logout icon
              title:
                  'Log out', // Changed from 'Logout' to 'Log out' as per image
              onTap: () {
                controller
                    .logout(); // Call the logout method from the ProfileController
              },
              isLogout: true, // Special styling for logout button
            ),
          ],
        ),
      ), // Custom bottom navigation bar
    );
  }

  // Helper method to build the custom bottom navigation bar
}

// Custom widget for individual profile option tiles
class _ProfileOptionTile extends StatelessWidget {
  final IconData icon; // Icon to display on the left
  final String title; // Title text for the option
  final VoidCallback onTap; // Callback function when the tile is tapped
  final bool isLogout; // Flag to apply special styling for the logout option

  const _ProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false, // Default value is false
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Attach the onTap callback
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ), // Inner padding
        decoration: BoxDecoration(
          color: Colors.white, // White background for the tile
          borderRadius: BorderRadius.circular(10), // Rounded corners
          border: Border.all(
            color: Colors
                .grey[200]!, // Light grey border to match the image's subtle separation
            width: 1,
          ),
          boxShadow:
              const [], // Removed shadows to match the flat design in the image
        ),
        child: Row(
          children: [
            // Circular container for the icon with a light grey background
            Container(
              padding: const EdgeInsets.all(8), // Padding around the icon
              decoration: BoxDecoration(
                color: Colors
                    .grey[200], // Light grey background for the icon circle
                shape: BoxShape.circle, // Circular shape
              ),
              child: Icon(
                icon, // The specific icon for this tile
                color: isLogout
                    ? Colors.black
                    : Colors
                          .black, // Icons are black regardless of logout status
              ),
            ),
            const SizedBox(width: 15), // Spacing between icon and text
            // Expanded widget for the title to take available space
            Expanded(
              child: Text(
                title, // The title text
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout
                      ? Colors.black
                      : Colors.black87, // Text color: black/dark grey
                ),
              ),
            ),
            // Chevron icon on the right
            Icon(
              Icons.chevron_right,
              color: Colors.grey[600],
            ), // Right arrow icon
          ],
        ),
      ),
    );
  }
}
