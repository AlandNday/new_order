// presentation/Homepage/homepage.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_order/infrastructure/navigation/routes.dart';
import 'package:new_order/presentation/BottomNavBar/controllers/bottom_nav_bar.controller.dart';
import 'package:new_order/presentation/Shopmenu/controllers/shopmenu.controller.dart';
import 'package:new_order/presentation/announcement/controllers/announcement.controller.dart';
import 'controllers/homepage.controller.dart';
import 'package:new_order/domain/core/Models/Review_model.dart'; // Import Review model

class HomepageScreen extends GetView<HomepageController> {
  const HomepageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final AnnouncementController announcementController =
        Get.find<AnnouncementController>();
    final BottomNavBarController bottomNavBarController =
        Get.find<BottomNavBarController>();
    final ShopmenuController shopmenuController =
        Get.find<ShopmenuController>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  child: Obx(() {
                    final String avatarUrl =
                        controller.userProfile.value?.avatarUrl ?? '';
                    print(
                      'DEBUG: Avatar URL being used: "$avatarUrl"',
                    ); // IMPORTANT: Log the actual URL
                    return ClipOval(
                      child: Image.network(
                        avatarUrl,
                        width: 2 * 24,
                        height: 2 * 24,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print(
                            'ERROR: Image.network failed to load: $error',
                          ); // Log the error object
                          return Icon(Icons.person, color: Colors.grey[600]);
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 12),
                Obx(
                  () => Flexible(
                    // Ensure flex is set, especially if you have other flex widgets
                    flex: 1, // This is the default, but good to be explicit
                    child: Text(
                      controller.userProfile.value?.name ?? '',
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Signature',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      bottomNavBarController.currentIndex.value = 1;
                    },
                    child: Text(
                      'More',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120, // Adjust height as needed
                child: Obx(
                  () => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: shopmenuController.products.isEmpty
                        ? 0
                        : 4, // Example: 4 favorite items
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        // Wrap the Column with a SizedBox to give it a fixed width
                        child: SizedBox(
                          width: 80, // Same width as your image container
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      // Ensure you handle potential null for imageUrl
                                      shopmenuController
                                          .products[index]
                                          .imageUrl,
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // The Text widget will now be constrained by the parent SizedBox's width
                              Text(
                                // Use null-aware operator for safety
                                shopmenuController.products[index].name ?? '',
                                textAlign: TextAlign
                                    .center, // Center the text within its fixed width
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                                maxLines:
                                    1, // Optional: Limit to 2 lines before ellipsizing
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Reviews Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(Routes.REVIEW); // Navigate to ReviewScreen
                    },
                    child: Text(
                      'Berikan Ulasan',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.isLoading.value && controller.reviews.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.reviews.isEmpty) {
                  return Center(
                    child: Text(
                      controller.errorMessage.value.isNotEmpty
                          ? controller.errorMessage.value
                          : 'No reviews available yet.',
                    ),
                  );
                }
                return SizedBox(
                  height: 160, // Adjust height as needed for review cards
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.reviews.length,
                    itemBuilder: (context, index) {
                      final Review review = controller.reviews[index];
                      List<Color?> cardColors = [
                        Colors.yellow[100],
                        Colors.green[100],
                        Colors.blue[100],
                        Colors.purple[100],
                      ];
                      // Use modulo to cycle through colors if there are more reviews than colors
                      Color? cardColor = cardColors[index % cardColors.length];

                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Container(
                          width:
                              MediaQuery.of(context).size.width *
                              0.8, // Adjust width
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[200],
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    review.reviewerName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                review.reviewText,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < review.starRating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.orange,
                                    size: 18,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 32),

              // Pengumuman Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pengumuman',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(Routes.ANNOUNCEMENT);
                    },
                    child: Text(
                      'More',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Original 'Row' containing the Card
              // NO Expanded here for the Card itself
              // The Card will take the available width provided by its parent,
              // which is the Column within the SingleChildScrollView.
              // That Column is implicitly constrained by the screen width minus padding.
              Card(
                color: Colors.grey[100],
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Placeholder for the "F*CK UP FLUCER" image
                          Container(
                            width: 120, // Has a fixed width
                            height: 150, // Has a fixed height
                            decoration: BoxDecoration(
                              color: Colors
                                  .yellow[700], // Approximate color from image
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              child: Obx(() {
                                if (announcementController
                                    .announcements
                                    .isEmpty) {
                                  return const Center(
                                    child: Icon(
                                      Icons.info,
                                      size: 50,
                                      color: Colors.blueGrey,
                                    ),
                                  );
                                }
                                return Image.network(
                                  announcementController
                                      .announcements[0]
                                      .imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                      "Error loading announcement image: $error",
                                    );
                                    return const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.red,
                                    );
                                  },
                                );
                              }),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            // This Expanded is correctly nested within a Row that has a bounded width (from its parent Card)
                            child: Obx(() {
                              if (announcementController
                                  .announcements
                                  .isEmpty) {
                                return const Text(
                                  'No announcement details available.',
                                );
                              }
                              final announcement =
                                  announcementController.announcements[0];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Event Name',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 0),
                                  Text(
                                    announcement.eventName,
                                    style: TextStyle(
                                      fontSize: 19,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 0),
                                  Text(
                                    announcement.date,
                                    style: TextStyle(
                                      fontSize: 19,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'Time',
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
                                    style: TextStyle(
                                      fontSize: 19,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 0),
                      Obx(() {
                        if (announcementController.announcements.isEmpty) {
                          return const Text('No description available.');
                        }
                        return Text(
                          announcementController.announcements[0].description,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
