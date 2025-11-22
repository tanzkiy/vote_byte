import 'package:flutter/material.dart';
import 'login_page.dart';
import 'widgets/app_background.dart';
import 'services/auth_service.dart';
import 'sdg_advocacy_screen.dart';
import 'edit_profile_screen.dart';
import 'dart:convert';
import 'dart:typed_data';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool notificationsOn = true;
  String userName = 'Loading...';
  String userEmail = 'Loading...';
  String userId = 'Loading...';
  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when returning from other screens
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthService.getCurrentUser();
    if (userData != null) {
      setState(() {
        userName = userData['name'] ?? 'Unknown';
        userEmail = userData['email'] ?? 'Unknown';
        userId = userData['uid'] ?? 'Unknown';
      });
    }
    final base64Image = await AuthService.getProfileImage();
    if (base64Image != null) {
      setState(() {
        try {
          final bytes = base64Decode(base64Image);
          _profileImageBytes = Uint8List.fromList(bytes);
        } catch (e) {
          // Invalid base64 - skip loading
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Clean minimal background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Account',
          style: TextStyle(
            color: Color(0xFF0D47A1),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Minimalistic User Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _profileImageBytes != null
                        ? ClipOval(
                            child: Image.memory(
                              _profileImageBytes!,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D47A1).withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 40,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userId,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Quick Actions Section
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 16),
              
              // Minimalistic Action Cards
              _buildActionCard(
                icon: Icons.public,
                title: 'SDGs',
                subtitle: 'Sustainable Development Goals',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SdgAdvocacyScreen(initialIndex: 0),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildActionCard(
                icon: Icons.campaign,
                title: 'Advocacy',
                subtitle: 'Advocacy Programs & Initiatives',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SdgAdvocacyScreen(initialIndex: 1),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildActionCard(
                icon: Icons.wc,
                title: 'GAD',
                subtitle: 'Gender and Development',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SdgAdvocacyScreen(initialIndex: 2),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Settings Section
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 16),
              
              // Enhanced Settings Cards
              _buildSettingsCard(
                icon: Icons.edit,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                  // Force refresh when returning from edit profile
                  _loadUserData();
                },
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Manage your notification preferences',
                trailing: Switch(
                  value: notificationsOn,
                  onChanged: (val) {
                    setState(() {
                      notificationsOn = val;
                    });
                  },
                  activeColor: Color(0xFF3B82F6),
                  activeTrackColor: Color(0xFF3B82F6).withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Vote BYTE App 0.1.0',
                onTap: () => _showAboutDialog(),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                icon: Icons.logout,
                title: 'Log Out',
                subtitle: 'Sign out of your account',
                onTap: () async {
                  await AuthService.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
                textColor: Colors.red,
              ),
              
              const SizedBox(height: 32),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF0D47A1), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black.withOpacity(0.3),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (textColor == Colors.red 
                        ? Colors.red.withOpacity(0.05)
                        : const Color(0xFF0D47A1).withOpacity(0.05)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: textColor ?? const Color(0xFF0D47A1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor ?? const Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor?.withOpacity(0.7) ?? Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing,
                if (trailing == null && onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: textColor?.withOpacity(0.5) ?? Colors.black.withOpacity(0.3),
                    size: 14,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF0D47A1), size: 24),
              SizedBox(width: 12),
              Text(
                'About Vote BYTE',
                style: TextStyle(
                  color: Color(0xFF0D47A1),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vote BYTE is a modern voting application designed to make democratic participation simple, secure, and accessible.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Version 0.1.0',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Built with Flutter',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: Color(0xFF0D47A1),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your privacy and security are our top priorities.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0D47A1),
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
