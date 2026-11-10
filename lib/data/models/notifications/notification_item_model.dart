
class NotificationItem {
  final String title;
  final String subtitle;
  final DateTime date;
  final String daysAgo;
  final String content;
  final String? imageAsset;

  NotificationItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.daysAgo,
    required this.content,
    this.imageAsset,
  });
}