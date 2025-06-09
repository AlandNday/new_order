import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For better image loading
import 'package:new_order/domain/core/models/order_model.dart'; // Ensure this path is correct
import 'package:new_order/presentation/adminorders/controllers/adminorders.controller.dart';

class AdminordersScreen extends GetView<AdminordersController> {
  const AdminordersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is initialized and put into GetX dependency injection
    Get.put(AdminordersController());

    return Scaffold(
      backgroundColor: Colors.white, // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(), // Navigates back
        ),
        title: Text(
          'List Order',
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
        if (controller.orders.isEmpty) {
          return Center(
            child: Text(
              'No orders found.',
              style: Get.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return buildOrderCard(order, index);
          },
        );
      }),
    );
  }

  Widget buildOrderCard(Order order, index) {
    String paymentStatusDisplayText;
    Color paymentButtonColor;
    VoidCallback? onPaymentButtonPressed;

    switch (order.paymentstatus) {
      case 'unverified':
        paymentStatusDisplayText = 'Pembayaran belum diverifikasi';
        paymentButtonColor = Colors.red[600]!;
        onPaymentButtonPressed = () =>
            controller.updatePaymentStatus(order.id, 'verified');
        break;
      case 'verified':
        paymentStatusDisplayText = 'Pembayaran sudah diverifikasi';
        paymentButtonColor = Colors.green;
        onPaymentButtonPressed = () {
          /* Do nothing */
        };
        break;

      default:
        paymentStatusDisplayText = 'Status pembayaran tidak diketahui';
        paymentButtonColor = Colors.blueGrey;
        onPaymentButtonPressed = null;
    }

    String orderStatusDisplayText;
    Color orderStatusColor;
    VoidCallback? onOrderStatusButtonPressed;
    bool isPaymentVerified = order.paymentstatus == 'verified';

    switch (order.status) {
      case 'pending':
        orderStatusDisplayText = 'Aktif';
        orderStatusColor = Colors.grey[700]!;
        // Set action ONLY if payment IS verified
        onOrderStatusButtonPressed = isPaymentVerified
            ? () => controller.updateOrderStatus(order.id, 'preparing')
            : null; // If payment NOT verified, it's null (i\active)
        break;
      case 'preparing':
        orderStatusDisplayText = 'Sedang disiapkan';
        orderStatusColor = Colors.orange[600]!;
        // Set action ONLY if payment IS verified
        onOrderStatusButtonPressed = isPaymentVerified
            ? () => controller.updateOrderStatus(order.id, 'completed')
            : null; // If payment NOT verified, it's null (inactive)
        break;
      case 'completed':
        orderStatusDisplayText = 'Selesai';
        orderStatusColor = Colors.green[600]!;
        onOrderStatusButtonPressed =
            null; // No action needed once completed, regardless of payment
        break;
      case 'cancelled':
        orderStatusDisplayText = 'Dibatalkan';
        orderStatusColor = Colors.grey[600]!;
        onOrderStatusButtonPressed =
            null; // No action needed once cancelled, regardless of payment
        break;
      default:
        orderStatusDisplayText = 'Status tidak diketahui';
        orderStatusColor = Colors.blueGrey;
        onOrderStatusButtonPressed = null;
    }

    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meja ${order.tableNumber}',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Waktu Order: ${order.timestamp.toDate().toLocal().toString().split('.')[0]}',
              style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            const Text('Bukti Pembayaran : '),
            const SizedBox(height: 5),
            // Safely display the image or a placeholder if URL is null
            if (order.paymentProofUrl != null &&
                order.paymentProofUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  // Use CachedNetworkImage for better performance
                  imageUrl: order.paymentProofUrl!,
                  width: double
                      .infinity, // Take full width/ Fixed height for consistency
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) {
                    print(
                      'ERROR: CachedNetworkImage failed to load for URL: $url - Error: $error',
                    );
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[600],
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(
                    'Tidak ada bukti pembayaran',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 15),

            // Display each item in the order
            ...order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  item.toDisplayString(), // Uses the toDisplayString from OrderItem
                  style: Get.textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 15),

            // Total Amount
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: Rp${order.totalAmount.toStringAsFixed(0)}',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Order Status Button
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: onOrderStatusButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orderStatusColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        orderStatusDisplayText,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Payment Status Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onPaymentButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: paymentButtonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        paymentStatusDisplayText,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
