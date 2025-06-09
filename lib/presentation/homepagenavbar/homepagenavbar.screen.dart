import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/homepagenavbar.controller.dart';

class HomepagenavbarScreen extends GetView<HomepagenavbarController> {
  const HomepagenavbarScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomepagenavbarScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'HomepagenavbarScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
