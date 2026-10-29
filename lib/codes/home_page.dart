import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'navigation_widgets.dart';
import 'settings_page.dart';
import 'collection_pages.dart';
import 'data_catalog_page.dart';
import '../services/veylora_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _styleFocus = 'Everyday';
  late final Future<CatalogResponse> _catalogFuture;

  @override
  void initState() {
    super.initState();
    _catalogFuture = _loadCatalog();
  }

  Future<CatalogResponse> _loadCatalog() async {
    try {
      return await VeyloraApi().fetchCatalog().timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {
      return const CatalogResponse(
        products: [
          CatalogProduct(
            id: 'linen-overshirt',
            name: 'Linen overshirt',
            category: 'Everyday essentials',
            price: 89,
            icon: 'checkroom',
            color: 0xFFE7D5C4,
            currencySymbol: '₱',
          ),
          CatalogProduct(
            id: 'structured-tote',
            name: 'Structured tote',
            category: 'Saved products',
            price: 120,
            icon: 'shopping_bag',
            color: 0xFFD8DDE8,
            currencySymbol: '₱',
          ),
          CatalogProduct(
            id: 'everyday-knit',
            name: 'Everyday knit',
            category: 'New arrival',
            price: 64,
            icon: 'dry_cleaning',
            color: 0xFFE0D8D0,
            currencySymbol: '₱',
          ),
        ],
        services: [
          CatalogService(
            id: 'personal-color-guide',
            name: 'Personal color guide',
            description:
                'Find colors that work with the pieces you already love.',
            icon: 'palette',
          ),
          CatalogService(
            id: 'style-consultation',
            name: 'Style consultation',
            description:
                'Get recommendations shaped around your taste and routine.',
            icon: 'support_agent',
          ),
          CatalogService(
            id: 'curated-shopping',
            name: 'Curated shopping',
            description:
                'Discover thoughtful additions for your everyday rotation.',
            icon: 'shopping_bag',
          ),
        ],
      );
    }
  }

  String get _title => switch (_selectedIndex) {
    1 => 'My wardrobe',
    2 => 'Style services',
    _ => 'Dashboard',
  };

  Widget get _content => switch (_selectedIndex) {
    1 => _buildWardrobe(),
    2 => _buildServices(),
    _ => _buildDashboard(),
  };

  void _showAddItemDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add wardrobe item'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Item name',
            hintText: 'e.g. Linen overshirt',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add item'),
          ),
        ],
      ),
    );
  }

  void _showPlanLookDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plan a look'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Occasion',
            hintText: 'e.g. Friday dinner',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create look'),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
  }

  void _openDataCatalog() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const DataCatalogPage()),
    );
  }

  void _openAccountDetails() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const AccountDetailsPage()),
    );
  }

  void _openEverydayEssentials() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const WardrobeCollectionPage(
          title: 'Everyday essentials',
          description: 'Your reliable pieces for easy, considered outfits.',
          items: ['Linen overshirt', 'Relaxed trousers', 'Leather sneakers'],
        ),
      ),
    );
  }

  void _openSavedProducts() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const WardrobeCollectionPage(
          title: 'Saved products',
          description:
              'Pieces you are considering for your next wardrobe edit.',
          items: ['Everyday knit', 'Structured tote', 'Minimal watch'],
        ),
      ),
    );
  }

  void _openFeaturedProducts(List<CatalogProduct> products) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => WardrobeCollectionPage(
          title: 'Featured products',
          description:
              'Explore the pieces selected for your current style focus.',
          items: products.map((product) => product.name).toList(),
        ),
      ),
    );
  }

  void _openStyleConsultation() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const StyleConsultationPage()),
    );
  }

  void _openPayment() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const PaymentPage()),
    );
  }

  void _openPersonalColorGuide() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const ServiceDetailPage(
          title: 'Personal color guide',
          description:
              'Find colors that work with the pieces you already love.',
          icon: Icons.palette_outlined,
        ),
      ),
    );
  }

  void _openCuratedShopping() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const ServiceDetailPage(
          title: 'Curated shopping',
          description:
              'Discover thoughtful additions for your everyday rotation.',
          icon: Icons.shopping_bag_outlined,
        ),
      ),
    );
  }

  void _openCatalogService(CatalogService service) {
    switch (service.id) {
      case 'personal-color-guide':
        _openPersonalColorGuide();
      case 'style-consultation':
        _openStyleConsultation();
      case 'curated-shopping':
        _openCuratedShopping();
    }
  }

  IconData _serviceIcon(String icon) => switch (icon) {
    'palette' => Icons.palette_outlined,
    'support_agent' => Icons.support_agent,
    'shopping_bag' => Icons.shopping_bag_outlined,
    _ => Icons.design_services_outlined,
  };

  IconData _productIcon(String icon) => switch (icon) {
    'shopping_bag' => Icons.shopping_bag_outlined,
    'dry_cleaning' => Icons.dry_cleaning_outlined,
    _ => Icons.checkroom,
  };

  Widget _buildDashboard() {
    final userEmail = Firebase.apps.isNotEmpty
        ? FirebaseAuth.instance.currentUser?.email
        : null;

    return FutureBuilder<CatalogResponse>(
      future: _catalogFuture,
      builder: (context, snapshot) => _buildDashboardContent(
        userEmail,
        snapshot.data ?? const CatalogResponse(products: [], services: []),
      ),
    );
  }

  Widget _buildDashboardContent(String? userEmail, CatalogResponse catalog) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'What are you wearing today?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Text(
                userEmail?.substring(0, 1).toUpperCase() ?? 'V',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          clipBehavior: Clip.antiAlias,
          color: const Color(0xFF2F2A35),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LOOK OF THE DAY',
                      style: TextStyle(
                        color: Color(0xFFE7B98A),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Icon(Icons.more_horiz, color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Soft tailoring',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Relaxed layers for a considered everyday look.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _lookSwatch(const Color(0xFFE2D3C3)),
                    _lookSwatch(const Color(0xFFB5A496)),
                    _lookSwatch(const Color(0xFF48434D)),
                    const SizedBox(width: 12),
                    const Text(
                      '3 pieces',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: _showPlanLookDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('View the full look'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _statCard('12', 'Wardrobe pieces', Icons.checkroom),
            _statCard('4', 'Saved products', Icons.favorite),
          ],
        ),
        const SizedBox(height: 24),
        _sectionHeading('Style focus', 'Personalized'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Everyday', 'Work', 'Weekend', 'Event']
                  .map(
                    (focus) => ChoiceChip(
                      label: Text(focus),
                      selected: _styleFocus == focus,
                      onSelected: (_) => setState(() => _styleFocus = focus),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            leading: Icon(
              Icons.lightbulb_outline,
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
            title: Text(
              'Styling tip for $_styleFocus',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
            subtitle: Text(
              'Start with one anchor piece, then build around its color and shape.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _sectionHeading('Your style week', '3 of 5 looks'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LinearProgressIndicator(value: 0.6),
                const SizedBox(height: 12),
                Text(
                  'Two more looks and you will complete your weekly styling goal.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => setState(() => _selectedIndex = 1),
                  icon: const Icon(Icons.checkroom),
                  label: const Text('Open my wardrobe'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _sectionHeading(
          'Featured products',
          'View collection',
          onTap: () => _openFeaturedProducts(catalog.products),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 238,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: catalog.products
                .map(
                  (product) => _productCard(
                    name: product.name,
                    category: product.category,
                    price:
                        '${product.currencySymbol}${product.price.toStringAsFixed(2)}',
                    icon: _productIcon(product.icon),
                    color: Color(product.color),
                    imageUrl: product.imageUrl,
                    onTap: () => _openFeaturedProducts(catalog.products),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
        _sectionHeading('Services for you', 'Explore services'),
        const SizedBox(height: 10),
        ...catalog.services.map(
          (service) => _serviceCard(
            icon: _serviceIcon(service.icon),
            title: service.name,
            description: service.description,
            onTap: () => _openCatalogService(service),
          ),
        ),
      ],
    );
  }

  Widget _productCard({
    required String name,
    required String category,
    required String price,
    required IconData icon,
    required Color color,
    String? imageUrl,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 178,
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: color,
                  child: imageUrl == null
                      ? Icon(
                          icon,
                          size: 58,
                          color: const Color(0xFF4D4650),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            icon,
                            size: 58,
                            color: const Color(0xFF4D4650),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeading(String title, String action, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: TextStyle(
              color: onTap == null
                  ? Theme.of(context).colorScheme.primary
                  : null,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _lookSwatch(Color color) {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return SizedBox(
      width: 156,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWardrobe() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Your collection',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text('Keep your favorite products together and ready to style.'),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.checkroom)),
            title: const Text('Everyday essentials'),
            subtitle: const Text('12 items ready to wear'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openEverydayEssentials,
          ),
        ),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.favorite_border)),
            title: const Text('Saved products'),
            subtitle: const Text('4 pieces on your wishlist'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openSavedProducts,
          ),
        ),
      ],
    );
  }

  Widget _buildServices() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Style services',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text('Use Veylora to make confident choices for every occasion.'),
        const SizedBox(height: 16),
        _serviceCard(
          icon: Icons.calendar_month_outlined,
          title: 'Outfit planner',
          description:
              'Combine your wardrobe into a look for work, weekends, or events.',
          onTap: _showPlanLookDialog,
        ),
        _serviceCard(
          icon: Icons.support_agent,
          title: 'Style consultation',
          description:
              'Get product recommendations shaped around your taste and routine.',
          onTap: _openStyleConsultation,
        ),
        _serviceCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Curated shopping',
          description:
              'Discover thoughtful additions for your everyday rotation.',
          onTap: _openCuratedShopping,
        ),
        _serviceCard(
          icon: Icons.credit_card_outlined,
          title: 'Make a payment',
          description: 'Pay your Veylora balance securely in a few steps.',
          onTap: _openPayment,
        ),
      ],
    );
  }

  Widget _serviceCard({
    IconData? icon,
    required String title,
    required String description,
    VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: icon == null ? null : CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(description),
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Veylora',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              _title,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You are all caught up.')),
              );
            },
            icon: const Icon(Icons.notifications_none),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Account details',
              onPressed: _openAccountDetails,
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                child: Text(
                  'V',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: VeyloraNavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        onDataCatalogPressed: _openDataCatalog,
        onSettingsPressed: _openSettings,
      ),
      body: _content,
      bottomNavigationBar: VeyloraNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
      ),
      floatingActionButton: switch (_selectedIndex) {
        1 => FloatingActionButton.extended(
          onPressed: _showAddItemDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add item'),
        ),
        _ => null,
      },
    );
  }
}
