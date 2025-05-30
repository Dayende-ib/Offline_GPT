import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final void Function(bool) toggleDarkMode;
  final bool isDarkMode;
  const SettingsScreen({
    super.key,
    required this.toggleDarkMode,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SwitchListTile(
            title: const Text('Mode sombre'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: toggleDarkMode,
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('Profil utilisateur'),
            subtitle: Text('Gérer votre profil'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('À propos'),
            subtitle: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }
}
