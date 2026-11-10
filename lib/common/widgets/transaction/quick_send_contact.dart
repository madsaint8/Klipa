import 'package:flutter/material.dart';
import '../../../data/models/quick_send/quick_send_model.dart';

Widget buildQuickSendContact(
  QuickSendContact contact, {
  required VoidCallback onTap,
}) {
  final isAddButton = contact.isAddButton;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              //  Avatar and Add button
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isAddButton
                    ? _AddIcon()
                    : _Avatar(profilePic: contact.profilePic),
              ),

              //  Frequency badge 
              // if (!isAddButton && contact.transferCount > 1)
              //   Positioned(
              //     top: -4,
              //     right: -4,
              //     child: Container(
              //       padding: const EdgeInsets.symmetric(
              //           horizontal: 5, vertical: 2),
              //       decoration: BoxDecoration(
              //         color: const Color(0xFF003366),
              //         borderRadius: BorderRadius.circular(10),
              //         border: Border.all(color: Colors.white, width: 1.5),
              //       ),
              //       child: Text(
              //         '${contact.transferCount}x',
              //         style: const TextStyle(
              //           color: Colors.white,
              //           fontSize: 9,
              //           fontWeight: FontWeight.w700,
              //         ),
              //       ),
              //     ),
              //   ),

              // Favorite star 
              if (!isAddButton && contact.isFavorite)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star,
                        color: Color(0xFF003366), size: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Name 
          SizedBox(
            width: 64,
            child: Text(
              isAddButton ? 'Add' : contact.displayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isAddButton ? FontWeight.w500 : FontWeight.w600,
                color: isAddButton
                    ? const Color(0xFF003366)
                    : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),

          // Last paid 
          if (!isAddButton && contact.lastPaidAt != null)
            SizedBox(
              width: 64,
              child: Text(
                _timeAgo(contact.lastPaidAt!),
                style: TextStyle(fontSize: 9, color: Colors.grey[400]),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    ),
  );
}

// ── Time ago helper ───────────────────────────────────────────────────────────

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}

// ── Internal widgets ──────────────────────────────────────────────────────────

class _AddIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF003366).withOpacity(0.3),
            width: 1.5,
          ),
          color: const Color(0xFF003366).withOpacity(0.06),
        ),
        child: const Icon(Icons.add, color: Color(0xFF003366), size: 26),
      );
}

class _Avatar extends StatelessWidget {
  final String? profilePic;
  const _Avatar({this.profilePic});

  @override
  Widget build(BuildContext context) {
    final hasImage = profilePic != null && profilePic!.isNotEmpty;

    return ClipOval(
      child: hasImage
          ? Image.network(
              profilePic!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _defaultIcon(),
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : _defaultIcon(),
            )
          : _defaultIcon(),
    );
  }

  Widget _defaultIcon() => Container(
        color: const Color(0xFF003366).withOpacity(0.08),
        child: const Icon(Icons.person,
            color: Color(0xFF003366), size: 28),
      );
}