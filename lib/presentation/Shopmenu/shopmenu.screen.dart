import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_order/domain/core/Models/ShopMenu_model.dart';
// Assuming you have CartController and ShopmenuController in their respective paths
import 'package:new_order/presentation/Cart/controllers/cart.controller.dart';
import 'controllers/shopmenu.controller.dart';

class ShopmenuScreen extends GetView<ShopmenuController> {
  const ShopmenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // You might need an instance of CartController if getProductQuantityInCart
    // is coming from there, or ensure your ShopmenuController has access.
    // For now, assuming controller.getProductQuantityInCart handles it.
    // final CartController cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      body: Column(
        children: [
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              height: 48, // Fixed height for the search bar
              decoration: BoxDecoration(
                color: Colors.grey[200], // Light grey background for search bar
                borderRadius: BorderRadius.circular(
                  12.0,
                ), // Less rounded corners
              ),
              child: TextField(
                onChanged: (value) => controller.updateSearchQuery(value),
                decoration: InputDecoration(
                  hintText: 'Search', // Changed hint text to 'Search'
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                  ), // Hint text color
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: Icon(
                    Icons.mic,
                    color: Colors.grey[600],
                  ), // Microphone icon
                  filled: true,
                  fillColor: Colors
                      .transparent, // Transparent as background is on Container
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none, // No border
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                ),
                style: const TextStyle(color: Colors.black87),
                cursorColor: Colors.black54,
              ),
            ),
          ),

          Obx(
            () => controller.filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      'No products found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(
                        16.0,
                      ), // Padding around the list
                      itemCount: controller.filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = controller.filteredProducts[index];

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 16.0,
                          ), // Spacing between cards
                          elevation: 0, // No shadow for cards
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10.0,
                            ), // Slightly less rounded corners
                          ),
                          color: Colors.white, // White background for cards
                          child: Padding(
                            padding: const EdgeInsets.all(
                              12.0,
                            ), // Padding inside the card
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Placeholder for the product image
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .grey[200], // Light grey placeholder
                                    borderRadius: BorderRadius.circular(8.0),
                                    image: DecorationImage(
                                      image: NetworkImage(product.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.description,
                                        style: TextStyle(
                                          fontSize:
                                              13, // Slightly smaller font for description
                                          color: Colors.grey[600],
                                        ),
                                        maxLines:
                                            3, // Limit description to 3 lines
                                        overflow: TextOverflow
                                            .ellipsis, // Add ellipsis if overflow
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ), // Increased space before button
                                      // The "Tambah ke Keranjang" button or quantity controls
                                      Obx(() {
                                        final int quantity = controller
                                            .getProductQuantityInCart(product);
                                        if (quantity == 0) {
                                          return Align(
                                            alignment: Alignment.centerRight,
                                            child: SizedBox(
                                              height:
                                                  36, // Fixed height for the button
                                              child: ElevatedButton(
                                                onPressed: () => controller
                                                    .addToCart(product),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors
                                                      .grey[800], // Darker background
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ), // Less rounded
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                      ), // Adjust padding
                                                  elevation: 0, // No shadow
                                                ),
                                                child: const Text(
                                                  'Tambah ke Keranjang', // Changed text
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ), // Smaller font size
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              height:
                                                  36, // Fixed height for the quantity controls
                                              decoration: BoxDecoration(
                                                color: Colors
                                                    .grey[800], // Darker background
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.remove,
                                                      color: Colors.white,
                                                      size:
                                                          18, // Smaller icon size
                                                    ),
                                                    onPressed: () => controller
                                                        .decreaseQuantityInCart(
                                                          product,
                                                        ),
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    padding: EdgeInsets
                                                        .zero, // Remove extra padding
                                                    constraints:
                                                        BoxConstraints(), // Remove default constraints
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4.0,
                                                        ),
                                                    child: Text(
                                                      '$quantity',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                      size:
                                                          18, // Smaller icon size
                                                    ),
                                                    onPressed: () => controller
                                                        .increaseQuantityInCart(
                                                          product,
                                                        ),
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    padding: EdgeInsets
                                                        .zero, // Remove extra padding
                                                    constraints:
                                                        BoxConstraints(), // Remove default constraints
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      }), // End Obx for quantity button
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
