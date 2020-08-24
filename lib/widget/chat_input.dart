import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nico_mqtt/pages/chat/chat_controller.dart';

class ChatInput extends StatelessWidget {
  ChatController get controller => Get.find<ChatController>();

//  final Function(String) onSend;
  const ChatInput({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      width: double.infinity,
      color: Colors.black38,
      padding: EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              onChanged: controller.onChangeInput,
              onEditingComplete: controller.onSendPress,
            ),
          ),
          const SizedBox(width: 10),
          Obx(
            () => FlatButton(
              onPressed: controller.onSendPress,
              child: Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }
}
