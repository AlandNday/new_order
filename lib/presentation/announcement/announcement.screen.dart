import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:new_order/domain/core/Models/Announcement_model.dart';

import 'controllers/announcement.controller.dart';

class AnnouncementScreen extends GetView<AnnouncementController> {
  const AnnouncementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Ensure the controller is initialized and put into GetX dependency injection
    // If using a binding, this isn't strictly needed here.

    return Scaffold(
      backgroundColor: Colors.white, // Or a light grey if preferred
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(), // Navigates back
        ),
        title: Text(
          'Pengumuman',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false, // Align title to the left
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyLarge?.copyWith(color: Colors.red),
            ),
          );
        }
        if (controller.announcements.isEmpty) {
          return Center(
            child: Text(
              'No announcements available.',
              style: Get.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: controller.announcements.length,
          itemBuilder: (context, index) {
            final announcement = controller.announcements[index];
            return buildAnnouncementCard(announcement);
          },
        );
      }),
    );
  }

  // Helper method to build a single announcement card
  Widget buildAnnouncementCard(Announcement announcement) {
    return Card(
      color: Colors.grey[100],
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
      ), // Add vertical margin for separation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Announcement Image
                Container(
                  width: 120,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Placeholder background
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      10,
                    ), // Apply radius to image
                    child: CachedNetworkImage(
                      imageUrl: announcement.imageUrl,
                      fit: BoxFit
                          .cover, // Ensures image fills the container and crops
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: Get.theme.primaryColor,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300], // Error background
                        child: Icon(
                          Icons.image_not_supported, // Icon for error
                          size: 60,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event Name', // Label as per your design
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(
                        height: 0,
                      ), // Use minimal spacing or none if desired
                      Text(
                        announcement.eventName,
                        style: TextStyle(fontSize: 19, color: Colors.grey[600]),
                      ),
                      const SizedBox(
                        height: 10,
                      ), // Increased spacing for readability

                      Text(
                        'Date', // Label
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 0),
                      Text(
                        announcement.date,
                        style: TextStyle(fontSize: 19, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        'Start Time', // Label
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 0),
                      Text(
                        announcement.startTime == ''
                            ? 'TBA'
                            : announcement.startTime,
                        style: TextStyle(fontSize: 19, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Spacing before description

            Text(
              'Description', // Label
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 0),
            Text(
              announcement.description,
              style: TextStyle(
                fontSize: 14, // Slightly larger font for description
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
