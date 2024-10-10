import 'package:flutter/material.dart';

class ButtonAssistant extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 1150),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(40),
          backgroundColor: Color.fromARGB(240, 21, 52, 72),
          ),
        child: const Text("Virtual \n Assistant", style: TextStyle(color: Colors.white, ),),
        ),
    );
  }
}