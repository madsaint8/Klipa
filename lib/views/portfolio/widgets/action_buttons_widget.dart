import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {

  final VoidCallback onReceive;
  final VoidCallback onSend;

  const ActionButtons({

    super.key,

    required this.onReceive,

    required this.onSend,

  });

  Widget button(
      String title,
      VoidCallback callback,
      ) {

    return Expanded(

      child: ElevatedButton(

        onPressed: callback,

        style: ElevatedButton.styleFrom(

          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(25),

          ),

          minimumSize: const Size(0,52),

        ),

        child: Text(title),

      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Row(

      children: [

        button("Receive", onReceive),

        const SizedBox(width:16),

        button("Send", onSend),

      ],

    );

  }

}