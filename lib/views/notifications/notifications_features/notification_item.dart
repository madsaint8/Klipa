import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/models/notifications/notification_item_model.dart';
import '../../../config/theme/colors/app_colors.dart';

class NotificationTemplate extends StatelessWidget {
  final NotificationItem notification;

  const NotificationTemplate({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notice',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                print('Settings icon');
              },
              icon: const Icon(Iconsax.trash,color: Colors.white,))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(14.0),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 13),
        height: notification.content.length + 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: AppColors.softGrey,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Text(
              notification.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // Image Section, only if imageAsset is provided
            if (notification.imageAsset != null)
              Center(
                child: Image.asset(
                  notification.imageAsset!,
                  height: 180,
                  width: 350,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 10),

            // Content Section
            Text(
              notification.content,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 