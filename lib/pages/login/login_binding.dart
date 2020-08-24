import 'package:get/get.dart';
import 'package:nico_mqtt/pages/login/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginController());
  }
}
