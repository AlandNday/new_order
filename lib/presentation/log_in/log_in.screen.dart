import 'package:color_hex/class/hex_to_color.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_order/infrastructure/navigation/routes.dart';

import 'controllers/log_in.controller.dart'; // Ensure correct import path

class LogInScreen extends GetView<LogInController> {
  const LogInScreen({super.key});
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
            SizedBox(height: 60),
            Text(
              'Log In',
              style: GoogleFonts.inter(
                fontSize: 29,
                textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 30),
            // Email TextField
            TextField(
              controller: controller.EmailController, // Assign controller
              decoration: InputDecoration(
                hintText: 'Email Adress',
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
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 0.0,
                ),
              ),
              keyboardType: TextInputType.emailAddress, // Set keyboard type
            ),
            SizedBox(height: 30),
            // Password TextField
            Obx(
              () => TextField(
                controller: controller.passwordController, // Assign controller
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
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  // Show/Hide Password Button
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
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 0.0,
                  ),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
              ),
            ),
            SizedBox(height: 30),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: null, // Call controller method
                child: Container(
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(color: hexToColor("#000000")),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 18),
            // Continue (Email/Password Login) Button
            Obx(
              () => Material(
                color: hexToColor('#505050'),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: controller.isLoading.value
                      ? null // Disable button if loading
                      : controller.signInWithEmail, // Call controller method
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 45,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: controller.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Continue",
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
                          textStyle: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : SizedBox.shrink(),
            ), // Use SizedBox.shrink for no space when no error
            // SizedBox(height: 10),
            // Center(
            //   child: Text(
            //     'Or',
            //     style: GoogleFonts.inter(
            //       textStyle: TextStyle(color: hexToColor("#000000")),
            //       fontSize: 13,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
            // SizedBox(height: 10),
            // // Continue With Google Button
            // Obx(
            //   () => Material(
            //     color: hexToColor('#D9D9D9'),
            //     borderRadius: BorderRadius.circular(8),
            //     child: InkWell(
            //       onTap: controller.isLoading.value
            //           ? null // Disable button if loading
            //           : controller.signInWithGoogle, // Call controller method
            //       borderRadius: BorderRadius.circular(8),
            //       child: Container(
            //         height: 45,
            //         width: double.infinity,
            //         alignment: Alignment.center,
            //         child: controller.isLoading.value
            //             ? CircularProgressIndicator(color: Colors.grey)
            //             : Text(
            //                 "Continue With Google",
            //                 style: GoogleFonts.inter(
            //                   textStyle: const TextStyle(color: Colors.white),
            //                   fontSize: 18,
            //                 ),
            //               ),
            //       ),
            //       splashColor: Colors.grey,
            //       highlightColor: Colors.grey,
            //     ),
            //   ),
            // ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don’t have an account?',
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(color: hexToColor("#000000")),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.SIGN_UP);
                  }, // Call controller method
                  child: Text(
                    ' Sign up',
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
