part of 'mqtt_bloc.dart';

abstract class MqttEvent extends Equatable {
  const MqttEvent();
}

class MqttEventConnecting extends MqttEvent {
  final String topic;

  const MqttEventConnecting({required this.topic});

  @override
  List<Object?> get props => [topic];
}

class MqttEventSubscribed extends MqttEvent {
  final String topic;

  const MqttEventSubscribed({required this.topic});

  @override
  List<Object?> get props => [topic];
}

class MqttEventListening extends MqttEvent {
  const MqttEventListening();

  @override
  List<Object?> get props => [];
}

class MqttEventSend extends MqttEvent {
  final List<String> message;

  const MqttEventSend({required this.message});

  @override
  List<Object?> get props => [message];
}
