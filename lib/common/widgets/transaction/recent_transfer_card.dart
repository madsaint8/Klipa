import 'package:flutter/material.dart';
import '../../../data/models/user/profile/quick_send_contact_model.dart';

Widget buildContactCard(QuickSendContact contact) {
  return Container(
    width: 115,
    height: 145,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            image: contact.assetImage != null
                ? DecorationImage(
                    image: AssetImage(contact.assetImage!),
                    fit: BoxFit.cover,
                  )
                : null,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: contact.icon != null
              ? Icon(
                  contact.icon,
                  color: Colors.blue,
                  size: 24,
                )
              : null,
        ),
        const SizedBox(height: 2),
        Text(
          contact.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        // Transfer date
        const Text("02 Sep"),
      ],
    ),
  );
}
