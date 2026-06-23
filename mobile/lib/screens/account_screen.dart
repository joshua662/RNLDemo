import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../utils/constants.dart';
import 'admin_shell.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class AccountScreen extends StatefulWidget {
  final bool embedded;

  const AccountScreen({super.key, this.embedded = false});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  User? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => isLoading = true);
    user = await AuthStorage.getUser();
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to manage orders.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final token = await AuthStorage.getToken();
    if (token != null) {
      try {
        await ApiService.logout(token);
      } catch (_) {}
    }
    await AuthStorage.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = user;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.skyLight,
                  child: Text(
                    (profile?.name.isNotEmpty == true
                            ? profile!.name[0]
                            : '?')
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile?.name ?? 'Customer',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  profile?.email ?? '',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              if (profile?.phone != null)
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Phone'),
                  subtitle: Text(profile!.phone!),
                ),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Account type'),
                subtitle: Text(
                  profile?.isAdmin == true ? 'Administrator' : 'Customer',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connected to IT9 backend',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'This app uses REST APIs (GET, POST, PUT, DELETE) with Laravel Sanctum bearer tokens. Data stays in sync with the web system.',
                  style: TextStyle(color: AppColors.muted, height: 1.4),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (profile != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) =>
                        profile.isAdmin ? const AdminShell() : const MainShell(),
                  ),
                );
              },
              icon: Icon(
                profile.isAdmin
                    ? Icons.admin_panel_settings_outlined
                    : Icons.receipt_long_outlined,
              ),
              label: Text(
                profile.isAdmin
                    ? 'Open admin workflow'
                    : 'Open customer workflow',
              ),
            ),
          ),
        OutlinedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.navy,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _buildBody();

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: _buildBody(),
    );
  }
}
