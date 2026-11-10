import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/theme/colors/app_colors.dart';
import '../../../data/models/quick_send/quick_send_model.dart';
import '../send_features/beneficiaries/pay_beneficiary/pay_beneficiary.dart';

class ContactsWidget extends StatefulWidget {
  const ContactsWidget({super.key});

  @override
  State<ContactsWidget> createState() => _ContactsWidgetState();
}

class _ContactsWidgetState extends State<ContactsWidget>
    with SingleTickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;
  bool _isExpanded = false;

  static const double _expandThreshold = 800.0;
  static const double _itemHeight = 80.0;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    );
    _scrollController.addListener(_onScroll);
    _fetchContacts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset >= _expandThreshold && !_isExpanded) {
      setState(() => _isExpanded = true);
      _expandController.forward();
    }
    if (_scrollController.offset <= 0 && _isExpanded) {
      setState(() => _isExpanded = false);
      _expandController.reverse();
    }
  }

  Future<void> _fetchContacts() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('beneficiaries')
          .select('''
            id,
            is_favorite,
            created_at,
            contact_user:contact_user_id (
              id,
              full_name,
              profile_pic,
              phone
            )
          ''')
          .eq('user_id', userId)
          .order('is_favorite', ascending: false)
          .order('created_at', ascending: false);

      setState(() {
        _contacts = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching contacts: $e');
    }
  }

  String _getInitials(String? fullName) {
    if (fullName == null || fullName.isEmpty) return '?';
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return fullName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final collapsedHeight =
            (_contacts.isEmpty ? 3 : _contacts.length.clamp(1, 10)) *
                    _itemHeight +
                32;

        final currentHeight = collapsedHeight +
            (_expandAnimation.value * (screenHeight - collapsedHeight));
        final currentWidth =
            screenWidth * (1.0 + (_expandAnimation.value * 0.1));
        final currentRadius = 15.0 * (1 - _expandAnimation.value);
        final currentElevation = _expandAnimation.value * 24.0;

        return Center(
          child: Material(
            elevation: currentElevation,
            borderRadius: BorderRadius.circular(currentRadius),
            clipBehavior: Clip.antiAlias,
            color: Colors.white,
            child: SizedBox(
              height: currentHeight,
              width: currentWidth,
              child: Column(
                children: [
                  // ── Header (expanded only) ──────────────────────────────
                  if (_expandAnimation.value > 0.3)
                    Opacity(
                      opacity: ((_expandAnimation.value - 0.3) / 0.7)
                          .clamp(0.0, 1.0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            const Text(
                              'Contacts',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003366),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_contacts.length} total',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Contact List ────────────────────────────────────────
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF003366)),
                          )
                        : _contacts.isEmpty
                            ? const Center(
                                child: Text('No contacts yet',
                                    style: TextStyle(color: Colors.grey)),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                physics: const BouncingScrollPhysics(),
                                itemCount: _contacts.length,
                                // ✅ No separator — no divider
                                itemBuilder: (context, index) {
                                  final beneficiary = _contacts[index];
                                  final recipientUser =
                                      beneficiary['contact_user']
                                          as Map<String, dynamic>?;

                                  final fullName =
                                      recipientUser?['full_name'] as String?;
                                  final phone =
                                      recipientUser?['phone'] as String?;
                                  final profilePic =
                                      recipientUser?['profile_pic'] as String?;
                                  final isFavorite =
                                      beneficiary['is_favorite'] as bool? ??
                                          false;

                                  final quickContact = QuickSendContact(
                                    id: beneficiary['id'] as String,
                                    name: fullName ?? 'Unknown',
                                    phone: phone,
                                    profilePic: profilePic,
                                    recipientId:
                                        recipientUser?['id'] as String?,
                                    isFavorite: isFavorite,
                                  );

                                  return buildContactItem(
                                    context: context,
                                    title: fullName ?? 'Unknown',
                                    subtitle: phone ?? '',
                                    profilePic: profilePic,
                                    initials: _getInitials(fullName),
                                    isFavorite: isFavorite,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PayBeneficiaryScreen(
                                            beneficiary: quickContact),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),

                  // ── Collapse handle (expanded only) ─────────────────────
                  if (_expandAnimation.value > 0.8)
                    Opacity(
                      opacity: ((_expandAnimation.value - 0.8) / 0.2)
                          .clamp(0.0, 1.0),
                      child: GestureDetector(
                        onTap: () => _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          color: Colors.grey[50],
                          child: const Icon(Icons.keyboard_arrow_down,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Updated buildContactItem
// ─────────────────────────────────────────────────────────────────────────────

Widget buildContactItem({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String initials,
  required VoidCallback onTap,
  String? profilePic,
  bool isFavorite = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Row(
        children: [
          // ── Avatar — profile pic or initials fallback ─────────────────
          _ContactAvatar(
            profilePic: profilePic,
            initials: initials,
          ),
          const SizedBox(width: 14),

          // ── Name + phone ──────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ── Trailing: favorite star or chevron ────────────────────────
          isFavorite
              ? const Icon(Icons.star, color: Color(0xFF003366), size: 18)
              : Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar widget — network image with initials fallback
// ─────────────────────────────────────────────────────────────────────────────

class _ContactAvatar extends StatelessWidget {
  final String? profilePic;
  final String initials;

  const _ContactAvatar({this.profilePic, required this.initials});

  @override
  Widget build(BuildContext context) {
    final hasImage = profilePic != null && profilePic!.isNotEmpty;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF003366).withOpacity(0.1),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                profilePic!,
                fit: BoxFit.cover,
                // ✅ Falls back to person icon if image fails to load
                errorBuilder: (_, __, ___) => _fallback(),
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _fallback();
                },
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => Center(
        child: Icon(
          Icons.person,
          color: const Color(0xFF003366).withOpacity(0.5),
          size: 26,
        ),
      );
}
