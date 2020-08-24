import 'dart:convert';

import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttConfig {
  final String host;
  final int port;
  final String client;

  MqttConfig([this.host = 'test.mosquitto.org', this.port = 1883, this.client]);
}

class MqttClient {
  MqttServerClient client;

  final MqttConfig config;
  String baseTopic = '/roipeker';
  String defaultSubTopic = 'chat';
  String _lastSubscriptionTopic;

  final isClientConnected = false.obs;

//  bool get isClientConnected => _isClientConnected.value;

  MqttClient(this.config) {
    _setup();
    print("Is client:: ${isClientConnected.value}");
  }

  void dispose() {
    disconnect();
    client = null;
  }

  void connect() async {
    await client?.connect();
  }

  void disconnect() {
    client?.disconnect();
  }

  bool get isConnected =>
      client.connectionStatus.state == MqttConnectionState.connected;

  String _cleanTopic(String topic) {
    topic ??= defaultSubTopic;
    topic = topic?.trim();
    if (topic.isEmpty) throw "Topic can't be empty spaces";
    if (!topic.startsWith('/')) topic = '/$topic';
    return topic;
  }

  void subs({String topic}) {
    topic = _cleanTopic(topic);
    _lastSubscriptionTopic = topic;
    final t = baseTopic + topic;
    client.subscribe(t, MqttQos.atMostOnce);
  }

//  String get lastSubscription {
//    if(!isConnected) return null;
//    return client.subscriptionsManager.subscriptions.entries.last.value.topic.rawTopic;
//  }

  void sendMessage({String message}) {
    if (!isConnected) return;
    if (_lastSubscriptionTopic == null) return;

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(
        _lastSubscriptionTopic, MqttQos.exactlyOnce, builder.payload);
  }

  void _setup() {
    client = MqttServerClient(
      config.host,
      config.client ?? 'flutter-user- ${DateTime.now().millisecond.hashCode}',
    );
    client.onConnected = () {
      isClientConnected.value = true;
      print('Client connect');
    };
    client.onDisconnected = () {
      print('Client disconnect');
      isClientConnected.value = false;
    };
  }

  void test() async {
    print('connecting');
    await client.connect();
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      return;
    }

    Future.delayed(Duration(seconds: 2), () {
      _sendDemoMessage();
    });

    print('connected');
    client.subscribe('/roipeker', MqttQos.atMostOnce);
//    _currentSub.changes.listen((event) {
//      print("event sub: $event");
//    });

    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });
  }

  void _sendDemoMessage() {
    final message = 'Hola nicoleta!';
    final topic = '/roipeker';
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    /// Subscribe to it
    print('EXAMPLE::Subscribing to topic');
    client.subscribe(topic, MqttQos.exactlyOnce);

    /// Publish it
    print('EXAMPLE::Publishing to $topic, mensaje: $message');
    var id = client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload);
    print('Send message id: $id');
  }
}

class ChatMessageMetadata {
  final String username;
  final String date;
  final String msg;

  String get dateUI {
    return date ?? DateTime.now().toString();
  }

  String get userInitials {
    return username[0].toUpperCase();
  }

  ChatMessageMetadata({this.username, this.date, this.msg});

  factory ChatMessageMetadata.fromJson(Map<String, dynamic> map) =>
      ChatMessageMetadata(
        username: map['client_id'] as String,
        date: map['date'] as String,
        msg: map['message'] as String,
      );

  Map<String, dynamic> toJson() => {
        'client_id': this.username?.toString(),
        'date': this.date?.toString(),
        'message': this.msg?.toString(),
      };

  @override
  String toString() {
    return 'ChatMessageMetadata{username: $username, date: $date, msg: $msg}';
  }
}

class ChatMessage {
  final String topic;
  final String message;
  final ChatMessageMetadata meta;

  ChatMessage([this.topic, this.message, this.meta]);

  factory ChatMessage.fromPayload(MqttReceivedMessage<MqttMessage> c) {
    final MqttPublishMessage recMess = c.payload;
    final pt =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    ChatMessageMetadata meta;
    try {
      meta = ChatMessageMetadata.fromJson(jsonDecode(pt));
    } catch (e) {
      print("Error converting json:: $e");
    }
//    print('notification:: topic is <${c.topic}>, payload is <-- $pt -->');
    return ChatMessage(
      c.topic,
      pt,
      meta,
    );
  }

  @override
  String toString() {
    return 'ChatMessage{topic: $topic, message: $message, meta: $meta}';
  }
}
