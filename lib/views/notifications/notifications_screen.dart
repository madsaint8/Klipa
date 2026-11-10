import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/notifications/notification_item_model.dart';
import '../../config/theme/colors/app_colors.dart';
import '../../core/utils/constants/uidata.dart';
import 'notifications_features/notification_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final showDateHeader = index == 0 ||
              !isSameDay(notifications[index - 1].date, notification.date);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDateHeader)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    _formatDate(notification.date),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              NotificationTile(notification: notification),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('MMM d, yyyy EEE');
    return formatter.format(date).toUpperCase();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class NotificationTile extends StatefulWidget {
  final NotificationItem notification;

  const NotificationTile({
    super.key,
    required this.notification,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  Color _noticeColor = Colors.green;

  void _changeColor() {
    setState(() {
      _noticeColor = AppColors.darkGrey.withOpacity(0.4);
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationTemplate(notification: widget.notification),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: ElevatedButton(
        onPressed: _changeColor,
        style: ElevatedButton.styleFrom(
          elevation: 0.0,
          backgroundColor: AppColors.softGrey, // Button background color
          fixedSize: const Size(380, 55), // Button size (width, height)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Button corner radius
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.notification.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _noticeColor,
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
