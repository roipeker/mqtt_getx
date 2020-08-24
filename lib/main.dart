import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nico_mqtt/pages/chat/chat_binding.dart';
import 'package:nico_mqtt/pages/chat/chat_page.dart';
import 'package:nico_mqtt/pages/login/login_binding.dart';
import 'package:nico_mqtt/pages/login/login_page.dart';

import 'mqtt_client.dart';

void main() {
  Get.put(
    MqttClient(MqttConfig()),
    permanent: true,
    tag: 'mqtt',
  );

  runApp(
    GetMaterialApp(
      defaultTransition: Transition.fadeIn,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      getPages: [
        GetPage(
          name: 'login',
          page: () => LoginPage(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: 'chat',
          page: () => ChatPage(),
          binding: ChatBinding(),
        ),
      ],
      initialRoute: 'chat',
    ),
  );
}
