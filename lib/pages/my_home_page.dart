import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_bloc_pattern/bloc/mqtt_bloc.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MqttBloc>().add(const MqttEventConnecting(topic: "demomqtt"));
    context.read<MqttBloc>().add(const MqttEventListening());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        centerTitle: true,
        title: const Text(
          'Mqtt - Bloc Pattern',
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocConsumer<MqttBloc, MqttState>(listener: (context, state) {
              if (state is MqttConnectedState) {
                context
                    .read<MqttBloc>()
                    .add(MqttEventSubscribed(topic: 'demomqtt'));
              }
            }, builder: (context, state) {
              if (state is MqttLoadingState) {
                return const Text('Connecting to the server...............',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black));
              }

              if (state is MqttConnectedState) {
                return Text(state.message,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black));
              }

              if (state is MqttDisconnectedState) {
                return Text(state.message,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black));
              }

              if (state is MqttSubscribedState) {
                return Text("Subscribed to: ${state.topic}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black));
              }

              if (state is MqttReceivedState) {
                return Expanded(
                  child: ListView.builder(
                      itemCount: state.message.length,
                      itemBuilder: (context, index) {
                        return Text(
                          state.message[index],
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        );
                      }),
                );
              }

              return Container();
            }),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: messageController,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        )),
                    onChanged: (value) {
                      messageController.text = value;
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                    onPressed: () {
                      context.read<MqttBloc>().add(MqttEventSend(
                          message: [messageController.text, "demomqtt"]));
                      messageController.clear();
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.deepPurple,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
