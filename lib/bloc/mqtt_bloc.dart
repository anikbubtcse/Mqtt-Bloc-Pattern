import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

part 'mqtt_event.dart';

part 'mqtt_state.dart';

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  final client = MqttServerClient.withPort("broker.hivemq.com", "", 1883);
  StreamSubscription? mqttSubscription;
  final List<String> messageList = [];

  MqttBloc() : super(MqttInitial()) {
    on<MqttEventConnecting>(_onMqttEventConnecting);
    on<MqttEventSubscribed>(_onMqttEventSubscribed);
    on<MqttEventListening>(_onMqttEventListening);
    on<MqttEventSend>(_onMqttEventMqttEventSend);
  }

  _onMqttEventConnecting(
      MqttEventConnecting event, Emitter<MqttState> state) async {
    emit(MqttLoadingState());

    client.setProtocolV31();
    client.logging(on: true);
    client.keepAlivePeriod = 120;
    client.autoReconnect = true;

    final MqttConnectMessage connectMessage = MqttConnectMessage()
        .withClientIdentifier(DateTime.now().toString())
        .startClean();
    client.connectionMessage = connectMessage;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      emit(const MqttConnectedState(message: "Connected to HiveMQ"));
    } else {
      emit(const MqttDisconnectedState(message: "Disconnected from HiveMq"));
    }
  }

  _onMqttEventSubscribed(MqttEventSubscribed event, Emitter<MqttState> state) {
    client.subscribe(event.topic, MqttQos.atLeastOnce);
    emit(MqttSubscribedState(topic: event.topic));
  }

  _onMqttEventListening(MqttEventListening event, Emitter<MqttState> state) {
    mqttSubscription =
        client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> msg) {
      emit(MqttLoadingState());
      final MqttPublishMessage recMessage =
          msg[0].payload as MqttPublishMessage;

      final pt =
          MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
      messageList.add(pt);
      emit(MqttReceivedState(message: messageList));
    });
  }

  _onMqttEventMqttEventSend(MqttEventSend event, Emitter<MqttState> state) {
    final String pubTopic = event.message[1];
    final builder = MqttClientPayloadBuilder();
    builder.addString(event.message[0]);
    client.subscribe(pubTopic, MqttQos.atLeastOnce);
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);
  }
}
