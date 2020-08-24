import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nico_mqtt/pages/chat/chat_controller.dart';
import 'package:nico_mqtt/widget/widgets.dart';

import '../../mqtt_client.dart';

class ChatPage extends GetView<ChatController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          UserAvatar(),
          SizedBox(width: 10),
        ],
      ),
      body: Obx(
        () => ListView.builder(
          controller: controller.chatScrollController,
          itemBuilder: (ctx, idx) =>
              ChatMessageItem(index: idx, model: controller.chatHistory[idx]),
          itemCount: controller.chatHistory.length,
          reverse: false,
        ),
      ),
      bottomNavigationBar: ChatInput(),
    );
  }
}

class ChatMessageItem extends StatelessWidget {
  final ChatMessage model;
  final int index;

  const ChatMessageItem({Key key, this.index, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = model.meta.username;
    final subtitle = model.meta.msg;
    return ListTile(
      title: Text("#$index :: $title"),
      subtitle: Text("$subtitle"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            child: Text(
              model.meta.userInitials,
            ),
          ),
        ],
      ),
    );
  }
}

class UserAvatar extends GetView<ChatController> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          GestureDetector(
            onTap: controller.onAvatarPress,
            child: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
          Obx(
            () => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: controller.isConnect ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
