import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

const navigationDestinations = [
  NavigationDestination(
    icon: Icon(Icons.dashboard_outlined),
    selectedIcon: Icon(Icons.dashboard),
    label: 'Dashboard',
  ),
  NavigationDestination(
    icon: Icon(Icons.checkroom_outlined),
    selectedIcon: Icon(Icons.checkroom),
    label: 'Wardrobe',
  ),
  NavigationDestination(
    icon: Icon(Icons.design_services_outlined),
    selectedIcon: Icon(Icons.design_services),
    label: 'Services',
  ),
];

const drawerDestinations = [
  NavigationDrawerDestination(
    icon: Icon(Icons.dashboard_outlined),
    selectedIcon: Icon(Icons.dashboard),
    label: Text('Dashboard'),
  ),
  NavigationDrawerDestination(
    icon: Icon(Icons.checkroom_outlined),
    selectedIcon: Icon(Icons.checkroom),
    label: Text('My wardrobe'),
  ),
  NavigationDrawerDestination(
    icon: Icon(Icons.design_services_outlined),
    selectedIcon: Icon(Icons.design_services),
    label: Text('Style services'),
  ),
];

class VeyloraNavigationBar extends StatelessWidget {
  const VeyloraNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: onDestinationSelected,
      destinations: navigationDestinations,
    );
  }
}

class VeyloraNavigationDrawer extends StatelessWidget {
  const VeyloraNavigationDrawer({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onDataCatalogPressed,
    required this.onSettingsPressed,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onDataCatalogPressed;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        onDestinationSelected(index);
        Navigator.pop(context);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 16, 16),
          child: Text(
            'Veylora',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        ...drawerDestinations,
        ListTile(
          leading: const Icon(Icons.dataset_outlined),
          title: const Text('Data Catalog'),
          onTap: () {
            Navigator.pop(context);
            onDataCatalogPressed();
          },
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 24, 16, 8),
          child: Text('Account'),
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context);
            onSettingsPressed();
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Sign out'),
          onTap: () {
            if (Firebase.apps.isNotEmpty) {
              FirebaseAuth.instance.signOut();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
