import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_storage.dart';
import 'admin_shell.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _authenticated = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      setState(() {
        _loading = false;
        _authenticated = false;
      });
      return;
    }

    try {
      final user = await ApiService.me(token);
      await AuthStorage.saveSession(token, user);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _authenticated = true;
        _isAdmin = user.isAdmin;
      });
    } catch (_) {
      await AuthStorage.clear();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _authenticated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_authenticated) return const LoginScreen();
    return _isAdmin ? const AdminShell() : const MainShell();
  }
}
