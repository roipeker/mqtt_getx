import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          FlatButton(
            onPressed: () {
              Get.toNamed('chat');
            },
            child: Text('chat'),
          ),
          IconButton(
            icon: Icon(
              Get.isDarkMode ? Icons.brightness_3 : Icons.brightness_high,
            ),
            onPressed: () => Get.changeThemeMode(
              Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
            ),
          ),
        ],
      ),
      body: Center(
        child: Text('login'),
      ),
    );
  }
}
