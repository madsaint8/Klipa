import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/user/profile/user_profile.dart';
import '../../providers/profile/profile_provider.dart';
import '../../providers/wallet/wallet_provider.dart';
import '../../services/auth/auth_service.dart';
import '../account_setup/welcome_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;

  // TODO: persist these (e.g. SharedPreferences or a settings provider).
  bool _biometricsEnabled = true;
  bool _notificationsEnabled = true;

  // --------------------------------------------------
  // PICK + UPLOAD PROFILE IMAGE
  // --------------------------------------------------
  Future<void> _pickImage() async {
    if (_isUploading) return;

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked == null) return;

    final ext = picked.name.contains('.')
        ? picked.name.split('.').last.toLowerCase()
        : 'jpg';

    setState(() => _isUploading = true);
    try {
      await ref.read(profileProvider.notifier).updateAvatar(
            file: File(picked.path),
            ext: ext,
            contentType: _contentTypeFor(ext),
          );
    } catch (e) {
      debugPrint('AVATAR UPLOAD ERROR: $e');
      _showMessage('Could not update profile picture. Please try again.');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  String _contentTypeFor(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------
  Future<void> _logout() async {
    try {
      await AuthServices().logout();
    } catch (e) {
      debugPrint('LOGOUT ERROR: $e');
      _showMessage('Could not log out. Please try again.');
      return;
    }

    ref.read(profileRepositoryProvider).clear();
    ref.invalidate(profileProvider);
    ref.invalidate(walletAccountProvider);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Keep the auth listener alive.
    ref.watch(authListenerProvider);

    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          debugPrint('PROFILE ERROR: $error\n$stack');
          return _ErrorView(
            onRetry: () => ref.read(profileProvider.notifier).refresh(),
          );
        },
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not found'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(profileProvider.notifier).refresh(),
            child: _buildContent(profile),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16),
        child: const SafeArea(
          top: false,
          child: Text(
            '© 2025 PayWave. All rights reserved.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(UserProfile profile) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(profile),
          const SizedBox(height: 24),
          _sectionTitle('Verification and features'),
          _tile('Klipa levels'),
          _tile('Theme mode', trailing: const Text('System')),
          _switchTile(
            title: 'Log in with biometrics',
            subtitle: 'Access your Klipa account quickly and securely.',
            value: _biometricsEnabled,
            onChanged: (v) => setState(() => _biometricsEnabled = v),
          ),
          _switchTile(
            title: 'Turn on notifications',
            subtitle: 'Receive real-time transaction alerts.',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          _tile('Personal details'),
          _tile('Connected apps and services'),
          _tile('Privacy settings'),
          _tile('Contact us'),
          _tile('Terms and Conditions'),
          _tile('Privacy Notice'),
          _tile('FAQ'),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Version 3.147.0',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _logout,
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserProfile profile) {
    final hasPic = profile.profilePic != null && profile.profilePic!.isNotEmpty;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 42.5,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: const AssetImage(
                    'assets/images/profile/Default.png',
                  ),
                  foregroundImage:
                      hasPic ? NetworkImage(profile.profilePic!) : null,
                  // Falls back to the default image if the network image fails.
                  onForegroundImageError: hasPic ? (_, __) {} : null,
                ),
                if (_isUploading)
                  const CircleAvatar(
                    radius: 42.5,
                    backgroundColor: Colors.black38,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.displayName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Customer ID: ${profile.customerId}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'True Waver',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // UI HELPERS
  // --------------------------------------------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _tile(String title, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap ?? () {},
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Unable to load profile'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}