import 'package:flutter/material.dart';
import 'package:simplex/assistente.dart';

class ButtonAssistant extends StatelessWidget {
  const ButtonAssistant({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 1210),
      child: Tooltip(
        message: 'Asistente virtual',
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(30),
            backgroundColor: const Color.fromARGB(240, 228, 155,56),
            ),
          child: const Icon(Icons.child_care, size: 40, color: Colors.white),
          ),
      ),
    );
  }
}