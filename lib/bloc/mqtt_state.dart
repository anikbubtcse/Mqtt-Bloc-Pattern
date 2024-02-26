part of 'mqtt_bloc.dart';

abstract class MqttState extends Equatable {
  const MqttState();
}

class MqttInitial extends MqttState {
  @override
  List<Object> get props => [];
}

class MqttLoadingState extends MqttState {
  @override
  List<Object> get props => [];
}

class MqttConnectedState extends MqttState {
  final String message;

  const MqttConnectedState({required this.message});

  @override
  List<Object> get props => [message];
}

class MqttDisconnectedState extends MqttState {
  final String message;

  const MqttDisconnectedState({required this.message});

  @override
  List<Object> get props => [message];
}

class MqttSubscribedState extends MqttState {
  final String topic;

  const MqttSubscribedState({required this.topic});

  @override
  List<Object> get props => [topic];
}

class MqttReceivedState extends MqttState {
  final List<String> message;

  const MqttReceivedState({required this.message});

  @override
  List<Object> get props => [message];
}
