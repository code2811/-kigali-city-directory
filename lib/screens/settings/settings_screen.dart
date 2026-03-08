import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  String? _notificationStatus;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text('Email: ${user.email}'),
              Text('Display Name: ${user.displayName?.isNotEmpty == true ? user.displayName : "Not set"}'),
              Row(
                children: [
                  Text('Email Verified: ${user.emailVerified ? "Yes" : "No"}'),
                  if (!user.emailVerified)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('Please verify your email!', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Location-based Notifications'),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: (val) {
                    setState(() {
                      _notificationsEnabled = val;
                      _notificationStatus = val ? 'Notifications enabled' : 'Notifications disabled';
                    });
                  },
                ),
              ],
            ),
            if (_notificationStatus != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_notificationStatus!, style: TextStyle(color: Colors.blueGrey)),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authProvider.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
