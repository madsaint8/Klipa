import 'package:flutter/material.dart';
import 'dart:ui';

Widget buildActionButton(String label, IconData icon, VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed, // Detect tap and trigger the callback
    child: Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(30), // Adjust to match rounded corners
        color: Colors.white
            .withOpacity(0.15), // More transparent for a better glass effect
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ), // Subtle border for contrast
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(30), // Match container's border radius
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 15.0, sigmaY: 15.0), // Increase blur for glassy look
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 50, vertical: 12), // Adjust padding
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    color: Colors.white, size: 20), // White icon for contrast
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16, // Adjust font size for better readability
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
