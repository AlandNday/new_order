import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_order/presentation/BottomNavBar/controllers/bottom_nav_bar.controller.dart';
import 'package:new_order/presentation/Cart/cart.screen.dart';
import 'package:new_order/presentation/Homepage/homepage.screen.dart';
import 'package:new_order/presentation/Shopmenu/shopmenu.screen.dart';
// import 'package:new_order/presentation/log_in/log_in.screen.dart'; // Not used in pages list
// import 'package:new_order/presentation/profile/controllers/profile.controller.dart'; // Controller not used directly in screen
import 'package:new_order/presentation/profile/profile.screen.dart';

class BottomNavBarScreen extends GetView<BottomNavBarController> {
  const BottomNavBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomepageScreen(),
      const ShopmenuScreen(),
      const CartScreen(),
      const ProfileScreen(),
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
              topLeft: Radius.circular(30.0), // Adjust radius as needed
              topRight: Radius.circular(30.0),
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
            child: BottomNavigationBar(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changePage,
              type: BottomNavigationBarType.fixed,
              backgroundColor:
                  Colors.white, // Ensure it's white to match the container
              selectedItemColor: Colors.black, // Selected icon color
              unselectedItemColor: Colors.grey[600], // Unselected icon color
              elevation:
                  0, // Remove default elevation as we're using Container's boxShadow
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
                      ? const Icon(Icons.apps) // Filled for selected
                      : const Icon(
                          Icons.apps_outlined,
                        ), // Outlined for unselected
                  label: '', // Empty label
                ),
                BottomNavigationBarItem(
                  icon: controller.currentIndex.value == 2
                      ? const Icon(Icons.shopping_cart) // Filled for selected
                      : const Icon(
                          Icons.shopping_cart_outlined,
                        ), // Outlined for unselected
                  label: '', // Empty label
                ),
                BottomNavigationBarItem(
                  icon: controller.currentIndex.value == 3
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
