import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_order/presentation/adminorders/adminorders.screen.dart';
import 'package:new_order/presentation/adminprofile/adminprofile.screen.dart';
import 'package:new_order/presentation/homepageadmin/homepageadmin.screen.dart';

import 'controllers/adminnavbar.controller.dart';

class AdminnavbarScreen extends GetView<AdminnavbarController> {
  const AdminnavbarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define your list of actual page widgets
    final List<Widget> pages = [
      const HomepageadminScreen(),
      const AdminordersScreen(),
      const AdminprofileScreen(),
    ];

    return Scaffold(
      body: Obx(
        () =>
            IndexedStack(index: controller.currentIndex.value, children: pages),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          // Wrap BottomNavigationBar in a Container for styling
          decoration: BoxDecoration(
            color: Colors.white, // Background color of the container
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0.0), // Adjust radius as needed
              topRight: Radius.circular(0.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3), // Subtle shadow
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, -3), // Shadow above the bar
              ),
            ],
          ),
          child: ClipRRect(
            // ClipRRect to apply borderRadius to the BottomNavigationBar content
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0.0),
              topRight: Radius.circular(0.0),
            ),
            child: BottomNavigationBar(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changePage,
              type: BottomNavigationBarType
                  .fixed, // Use fixed if you have 3-5 items
              backgroundColor:
                  Colors.white, // Ensure it's white to match the container
              selectedItemColor: Colors.black, // Selected icon color
              unselectedItemColor: Colors.grey[600], // Unselected icon color
              elevation:
                  0, // Remove default elevation as we're using Container's boxShadowa
              items: [
                BottomNavigationBarItem(
                  icon: controller.currentIndex.value == 0
                      ? const Icon(Icons.home) // Filled for selected
                      : const Icon(
                          Icons.home_outlined,
                        ), // Outlined for unselected
                  label: '', // Empty label
                ),
                BottomNavigationBarItem(
                  icon: controller.currentIndex.value == 1
                      ? const Icon(
                          Icons.receipt_long,
                        ) // Changed from 'apps' to 'explore' to match your admin's current icons
                      : const Icon(
                          Icons.receipt_long_outlined,
                        ), // Outlined for unselected
                  label: '', // Empty label
                ),
                BottomNavigationBarItem(
                  icon: controller.currentIndex.value == 2
                      ? const Icon(Icons.person) // Filled for selected
                      : const Icon(
                          Icons.person_outline,
                        ), // Outlined for unselected
                  label: '', // Empty label
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
