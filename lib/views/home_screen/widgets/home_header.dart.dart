import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:iconsax/iconsax.dart';
import '../../../config/theme/constants/text_strings.dart';
import '../../notifications/notifications_screen.dart';
import '../../profile/profile_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.fullName,
    this.avatar, 
  });

  final String fullName;
  final String? avatar; 

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Profile image ─────────────────────────────────────────────
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
            child: ClipOval(
              child: _buildAvatar(),
            ),
          ),
        ),

        // ── Welcome text ──────────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppTexts.homeAppbarTitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              Text(
                fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // ── Notifications ─────────────────────────────────────────────
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: const Center(
                  child: Icon(Iconsax.notification, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    // ✅ Only use NetworkImage when avatar is a non-empty string
    if (avatar != null && avatar!.isNotEmpty) {
      return Image.network(
        avatar!,
        fit: BoxFit.cover,
        // ✅ Fallback if image fails to load
        errorBuilder: (_, __, ___) => _defaultIcon(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _defaultIcon(),
      );
    }
    return _defaultIcon();
  }

  Widget _defaultIcon() => const Center(
        child: Icon(Icons.person, color: Colors.white, size: 30),
      );
}