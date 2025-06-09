import 'package:color_hex/class/hex_to_color.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_order/infrastructure/navigation/routes.dart';

import 'controllers/sign_up.controller.dart';

class SignUpScreen extends GetView<SignUpController> {
  const SignUpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Back'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 29),
        child: ListView(
          children: [
            const SizedBox(height: 60),
            Text(
              'Sign Up',
              style: GoogleFonts.inter(
                fontSize: 29,
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Email TextField
            TextField(
              controller: controller.emailController,
              decoration: InputDecoration(
                hintText: 'Email Address',
                hintStyle: GoogleFonts.inter(
                  textStyle: TextStyle(color: hexToColor("#000000")),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: hexToColor("#000000")),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: hexToColor("#000000"),
                    width: 3.0,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 0.0,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 30),
            // Password TextField
            Obx(
              () => TextField(
                controller: controller.passwordController,
                obscureText: controller.isPasswordHidden.value,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: GoogleFonts.inter(
                    textStyle: TextStyle(color: hexToColor("#000000")),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: hexToColor("#000000"),
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: hexToColor("#000000"),
                      width: 3.0,
                    ),
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  suffix: InkWell(
                    onTap: () {
                      controller.isPasswordHidden.value =
                          !controller.isPasswordHidden.value;
                    },
                    child: Text(
                      controller.isPasswordHidden.value
                          ? "Show Password"
                          : "Hide Password",
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(color: hexToColor("#B9B9B9")),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 0.0,
                  ),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(height: 30),
            // Confirm Password TextField
            Obx(
              () => TextField(
                controller: controller.confirmPasswordController,
                obscureText: controller.isConfirmPasswordHidden.value,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  hintStyle: GoogleFonts.inter(
                    textStyle: TextStyle(color: hexToColor("#000000")),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: hexToColor("#000000"),
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: hexToColor("#000000"),
                      width: 3.0,
                    ),
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  suffix: InkWell(
                    onTap: () {
                      controller.isConfirmPasswordHidden.value =
                          !controller.isConfirmPasswordHidden.value;
                    },
                    child: Text(
                      controller.isConfirmPasswordHidden.value
                          ? "Show Password"
                          : "Hide Password",
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(color: hexToColor("#B9B9B9")),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 0.0,
                  ),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(height: 30),
            // Sign Up Button
            Obx(
              () => Material(
                color: hexToColor('#505050'),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: controller.isLoading.value
                      ? null // Disable button if loading
                      : controller.signUpWithEmail, // Call controller method
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 45,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Sign Up",
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(color: Colors.white),
                              fontSize: 18,
                            ),
                          ),
                  ),
                  splashColor: Colors.grey,
                  highlightColor: Colors.grey,
                ),
              ),
            ),
            // Display Error Message
            Obx(
              () => controller.errorMessage.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        controller.errorMessage.value,
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(color: hexToColor("#000000")),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                InkWell(
                  onTap: () =>
                      Get.toNamed(Routes.LOG_IN), // Navigate to login screen
                  child: Text(
                    ' Log In',
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(color: hexToColor("#000000")),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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
