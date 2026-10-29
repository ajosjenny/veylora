import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _personalizedRecommendations = true;

  void _openAccountDetails() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const AccountDetailsPage()),
    );
  }

  void _openPrivacyAndSecurity() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const PrivacySecurityPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Your preferences',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize how Veylora supports your personal style.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Style reminders'),
                  subtitle: const Text(
                    'Get updates about saved looks and services.',
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.recommend_outlined),
                  title: const Text('Personalized recommendations'),
                  subtitle: const Text(
                    'Use your wardrobe to improve product suggestions.',
                  ),
                  value: _personalizedRecommendations,
                  onChanged: (value) {
                    setState(() => _personalizedRecommendations = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Account details'),
                  subtitle: const Text(
                    'Manage your profile and sign-in information.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _openAccountDetails,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Privacy and security'),
                  subtitle: const Text('Review how your Veylora data is used.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _openPrivacyAndSecurity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AccountDetailsPage extends StatelessWidget {
  const AccountDetailsPage({super.key});

  void _editDisplayName(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit display name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Display name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final user = Firebase.apps.isNotEmpty
                  ? FirebaseAuth.instance.currentUser
                  : null;
              if (user != null && controller.text.trim().isNotEmpty) {
                await user.updateDisplayName(controller.text.trim());
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _showEmailInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Email address'),
        content: Text(
          Firebase.apps.isNotEmpty
              ? FirebaseAuth.instance.currentUser?.email ??
                    'No email address available.'
              : 'Email details are available after sign-in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Firebase.apps.isNotEmpty
        ? FirebaseAuth.instance.currentUser
        : null;
    final displayName = user?.displayName?.trim();
    final email = user?.email;
    final accountLabel = displayName == null || displayName.isEmpty
        ? 'Veylora member'
        : displayName;
    final emailLabel = email == null || email.isEmpty
        ? 'No email address available'
        : email;
    final providerLabel = user?.providerData.isNotEmpty == true
        ? user!.providerData.first.providerId
        : 'Veylora account';

    return Scaffold(
      appBar: AppBar(title: const Text('Account details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Your profile',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text('Keep your Veylora profile information up to date.'),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Display name'),
                  subtitle: Text(accountLabel),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _editDisplayName(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email address'),
                  subtitle: Text(emailLabel),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showEmailInfo(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text('Sign-in method'),
                  subtitle: Text(providerLabel),
                ),
                if (user?.uid != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('User ID'),
                    subtitle: Text(user!.uid),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool _analyticsEnabled = true;

  void _showPrivacyPolicy() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Veylora privacy policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Veylora uses your account and wardrobe preferences to provide styling features. We do not sell your personal information.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _downloadData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your data export is being prepared.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy and security')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Your privacy matters',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Control how your information supports the Veylora experience.',
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.insights_outlined),
                  title: const Text('Anonymous analytics'),
                  subtitle: const Text(
                    'Help improve the app without sharing personal content.',
                  ),
                  value: _analyticsEnabled,
                  onChanged: (value) {
                    setState(() => _analyticsEnabled = value);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Privacy policy'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: _showPrivacyPolicy,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Download my data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _downloadData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
