import 'package:get/get.dart';
import 'package:nico_mqtt/pages/chat/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ChatController());
  }
}
