import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/checkoutpayment.controller.dart';
import 'dart:io'; // Required for File image

class CheckoutpaymentScreen extends GetView<CheckoutpaymentController> {
  const CheckoutpaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Controller Initialization ---
    // This line is REMOVED! GetX will automatically find the controller
    // provided by the binding.
    // Get.put(CheckoutpaymentController()); // <--- REMOVE THIS LINE!

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text(
          'Pembayaran QRIS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // QR Code Section
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Image.network(
                  'https://res.cloudinary.com/dh1btqzox/image/upload/v1749496907/image_7_vaxlwi.png',
                  width: Get.width * 0.7,
                  height: Get.width * 0.7,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),

              // Total Payment Section
              const Text(
                'Total Yang perlu Dibayar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Obx(
                () => Text(
                  'Rp${controller.totalAmount.value.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Payment Proof Section
              const Text(
                'Bukti Pembayaran :',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  controller.pickImage();
                },
                child: Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: controller.selectedImage.value != null
                        ? Column(
                            children: [
                              Image.file(
                                controller.selectedImage.value!,
                                height: 150,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'File Dipilih: ${controller.selectedImage.value!.path.split('/').last}',
                                style: const TextStyle(color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file, color: Colors.grey),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  'Silakan Unggah Bukti Pembayaran QRIS',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Error Message Display
              Obx(
                () => controller.errorMessage.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Text(
                          controller.errorMessage.value,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Submit Button
              Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isSubmitting.value ||
                          controller.selectedImage.value == null
                      ? null
                      : controller.submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
