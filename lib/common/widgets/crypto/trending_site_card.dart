import 'package:flutter/material.dart';
import '../../../data/models/crypto/trending_site.dart';

class TrendingSiteCard extends StatelessWidget {
  const TrendingSiteCard(this.site, {super.key});
  final TrendingSite site;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: site.iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(site.icon, color: site.iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              site.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.black,
            size: 16,
          ),
        ],
      ),
    );
  }
}
