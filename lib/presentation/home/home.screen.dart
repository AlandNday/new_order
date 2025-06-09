import 'package:color_hex/class/hex_to_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_order/infrastructure/navigation/routes.dart';
import 'controllers/home.controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor("#505050"),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 200),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NEW;ORDER',
                style: GoogleFonts.inter(
                  fontSize: 40,
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 1),
                    child: Text(
                      '©',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 250),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: hexToColor('#D9D9D9'),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  Get.toNamed(Routes.LOG_IN);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 45,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    "let's Go",
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(color: Colors.blueGrey),
                      fontSize: 18,
                    ),
                  ),
                ),
                splashColor: Colors.blueAccent.withOpacity(0.3),
                highlightColor: Colors.blueAccent.withOpacity(0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
