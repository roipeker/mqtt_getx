import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../mqtt_client.dart';

class ChatController extends GetxController {
  final _client = Get.find<MqttClient>(tag: 'mqtt');
  final _message = ''.obs;

  final ScrollController chatScrollController = ScrollController();

  final _chatHistory = <ChatMessage>[].obs;

  List<ChatMessage> get chatHistory => _chatHistory.value;

  void onChangeInput(String message) {
    _message.value = message;
  }

  Function get onSendPress {
    if (_message.value.trim().isEmpty) {
      return null;
    } else {
      return _onSendPress;
    }
  }

  void onAvatarPress() {
    if (_client.isConnected) {
      _client.disconnect();
    } else {
      _client.connect();
    }
  }

  void _onSendPress() {
    final chatJson = ChatMessageMetadata(
      username: 'guest',
      date: DateTime.now().toIso8601String(),
      msg: _message.value,
    ).toJson();
    var output = jsonEncode(chatJson);
    print("output message: $output");
    _client.sendMessage(output);
  }

  final _isConnected = false.obs;

  bool get isConnect => _isConnected.value;

  @override
  void onInit() {
    _client.isClientConnected.listen((data) {
      _isConnected.value = data;
      if (data) {
        _chatHistory.clear();
        _client.client.updates.listen(_onMessageArrived);
        _client.subs(topic: 'chat');
      } else {
        _chatHistory.clear();
      }
    });
  }

  @override
  void onReady() {
    _client.connect();
  }

  @override
  void onClose() {
    chatScrollController.dispose();
  }

  void _onMessageArrived(event) {
    final msg = ChatMessage.fromPayload(event[0]);
    print(msg);
    _chatHistory.add(msg);
    Timer(Duration(milliseconds: 16), _scrollToBottom);
//    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!chatScrollController.hasClients) return;
    final pos = chatScrollController.position;
    pos.animateTo(
      pos.maxScrollExtent,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOutExpo,
    );
  }
}
