import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:new_order/infrastructure/navigation/routes.dart';
import 'package:new_order/presentation/announcement/controllers/announcement.controller.dart';
import 'package:new_order/presentation/screens.dart';

import 'controllers/homepageadmin.controller.dart';

class HomepageadminScreen extends GetView<HomepageadminController> {
  const HomepageadminScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Get.lazyPut<AdminordersScreen>(() => AdminordersScreen());

    final AdminordersScreen adminordersScreen = Get.find<AdminordersScreen>();
    final AnnouncementController announcementController =
        Get.find<AnnouncementController>();

    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              // --- Top Bar (Simulated Status Bar) ---
              // In a real app, this would be handled by the OS or a custom AppBar.
              // For simulation, we'll add some padding at the top.
              // --- User Profile Section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                              // Optionally, print stackTrace during development for deeper insights
                              // print('STACK TRACE: $stackTrace');
                              return Icon(
                                Icons.person,
                                color: Colors.grey[600],
                              );
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 12),
                    Obx(
                      () => Text(
                        controller.userProfile.value?.name ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- Pengumuman (Announcement) Section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pengumuman',
                      style: TextStyle(
                        fontSize: 20,
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
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
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
                              width: 120,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors
                                    .yellow[700], // Approximate color from image
                                borderRadius: BorderRadius.circular(10),
                                // You would use Image.asset('assets/your_image.png') here
                                // For now, let's use a placeholder with some text
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.all(
                                  Radius.circular(10),
                                ),
                                child: Obx(
                                  () => Image.network(
                                    announcementController
                                        .announcements[0]
                                        .imageUrl,
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
                                    'Event Name',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 0),
                                  Obx(
                                    () => Text(
                                      announcementController
                                          .announcements[0]
                                          .eventName,
                                      style: TextStyle(
                                        fontSize: 19,
                                        color: Colors.grey[600],
                                      ),
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
                                  Obx(
                                    () => Text(
                                      announcementController
                                          .announcements[0]
                                          .date,
                                      style: TextStyle(
                                        fontSize: 19,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Start Time',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 0),
                                  Obx(
                                    () => Text(
                                      announcementController
                                          .announcements[0]
                                          .startTime,
                                      style: TextStyle(
                                        fontSize: 19,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Add more details if necessary based on the image
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 0),
                        Text(
                          'A pop-up kitchen by tujusepuluh',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- Pesanan Baru (New Order) Section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Pesanan Baru',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Red badge with number 3
                        // Container(
                        //   padding: const EdgeInsets.all(5),
                        //   decoration: BoxDecoration(
                        //     color: Colors.redAccent,
                        //     shape: BoxShape.circle,
                        //   ),
                        //   child: Text(
                        //     '3',
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //       fontWeight: FontWeight.bold,
                        //       fontSize: 14,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle More button press
                      },
                      child: Text(
                        'More',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(
                  () => adminordersScreen.buildOrderCard(
                    adminordersScreen.controller.orders[0],
                    0,
                  ),
                ),
              ),
              const SizedBox(height: 30), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
