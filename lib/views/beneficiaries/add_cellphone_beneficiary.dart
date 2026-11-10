import 'package:flutter/material.dart';
import '../../controllers/beneficiary_controllers/add_beneficiary_controller.dart';


class AddBeneficiarySheet extends StatefulWidget {
  /// Called after a beneficiary is successfully added
  final VoidCallback? onAdded;

  const AddBeneficiarySheet({super.key, this.onAdded});

  static Future<void> show(BuildContext context, {VoidCallback? onAdded}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBeneficiarySheet(onAdded: onAdded),
    );
  }

  @override
  State<AddBeneficiarySheet> createState() => _AddBeneficiarySheetState();
}

class _AddBeneficiarySheetState extends State<AddBeneficiarySheet>
    with SingleTickerProviderStateMixin {
  late final AddBeneficiaryController _controller;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AddBeneficiaryController()..addListener(_rebuild);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _controller
      ..removeListener(_rebuild)
      ..dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: screenHeight * 0.85,
        padding: EdgeInsets.only(bottom: bottomPadding),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHandle(),
            _SheetHeader(
              selectedContact: _controller.selectedContact,
              onBack: _controller.clearSelection,
            ),
            const SizedBox(height: 8),
            if (_controller.selectedContact == null) ...[
              _SearchBar(
                controller: _controller.searchController,
                onChanged: _controller.onSearchChanged,
              ),
              const SizedBox(height: 12),
              Expanded(child: _ContactList(controller: _controller)),
            ] else ...[
              Expanded(
                child: _ConfirmStep(
                  controller: _controller,
                  onConfirm: () async {
                    final success = await _controller.addBeneficiary();
                    if (success && context.mounted) {
                      widget.onAdded?.call();
                      Navigator.of(context).pop();
                      _showSuccessSnackbar(context);
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context) {
    final name = _controller.selectedContact?['full_name'] ?? 'Contact';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added as beneficiary'),
        backgroundColor: const Color(0xFF003366),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 4),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final Map<String, dynamic>? selectedContact;
  final VoidCallback onBack;

  const _SheetHeader({required this.selectedContact, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          if (selectedContact != null)
            GestureDetector(
              onTap: onBack,
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.arrow_back_ios_new,
                    size: 18, color: Color(0xFF003366)),
              ),
            ),
          Text(
            selectedContact == null ? 'Add Beneficiary' : 'Confirm Beneficiary',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF003366),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search by name or phone...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF003366)),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: const Icon(Icons.close, size: 18),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF4F6FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _ContactList extends StatelessWidget {
  final AddBeneficiaryController controller;

  const _ContactList({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF003366)),
      );
    }

    if (controller.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(controller.error!,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: controller.loadUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final users = controller.filteredUsers;

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_search, color: Colors.grey[300], size: 56),
            const SizedBox(height: 12),
            Text(
              controller.searchQuery.isEmpty
                  ? 'No users found'
                  : 'No results for "${controller.searchQuery}"',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = users[index];
        final isAlreadyAdded = controller.existingContactIds.contains(user['id']);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: _Avatar(name: user['full_name']),
          title: Text(
            user['full_name'] ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            user['phone'] ?? '',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: isAlreadyAdded
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Added',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                )
              : const Icon(Icons.chevron_right,
                  color: Color(0xFF003366), size: 20),
          onTap: isAlreadyAdded ? null : () => controller.selectContact(user),
        );
      },
    );
  }
}

class _ConfirmStep extends StatelessWidget {
  final AddBeneficiaryController controller;
  final VoidCallback onConfirm;

  const _ConfirmStep({required this.controller, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final contact = controller.selectedContact!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          _Avatar(name: contact['full_name'], radius: 40, fontSize: 24),
          const SizedBox(height: 16),
          Text(
            contact['full_name'] ?? 'Unknown',
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF003366)),
          ),
          const SizedBox(height: 4),
          Text(
            contact['phone'] ?? '',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF003366), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This person will be added to your beneficiary list and will be able to receive transfers from you.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (controller.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                controller.error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.isSubmitting ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: controller.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Confirm & Add',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? name;
  final double radius;
  final double fontSize;

  const _Avatar({this.name, this.radius = 22, this.fontSize = 14});

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name![0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF003366),
      child: Text(
        _initials,
        style: TextStyle(color: Colors.white, fontSize: fontSize),
      ),
    );
  }
}