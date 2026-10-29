import 'package:flutter/material.dart';

class WardrobeCollectionPage extends StatelessWidget {
  const WardrobeCollectionPage({
    required this.title,
    required this.description,
    required this.items,
    super.key,
  });

  final String title;
  final String description;
  final List<String> items;

  void _showItem(BuildContext context, String item) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item),
        content: const Text(
          'This wardrobe piece is ready to style with your saved looks.',
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
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 20),
          ...items.map(
            (item) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.checkroom)),
                title: Text(item),
                subtitle: const Text('Ready to style'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showItem(context, item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StyleConsultationPage extends StatelessWidget {
  const StyleConsultationPage({super.key});

  void _chooseTime(BuildContext context) {
    showTimePicker(context: context, initialTime: TimeOfDay.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Style consultation')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Find your next favorite look.',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us about your routine and our Veylora stylists will shape recommendations around you.',
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Book a consultation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get a considered edit for work, weekends, or a special occasion.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _chooseTime(context),
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: const Text('Choose a time'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceDetailPage extends StatelessWidget {
  const ServiceDetailPage({
    required this.title,
    required this.description,
    required this.icon,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          CircleAvatar(radius: 30, child: Icon(icon, size: 28)),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start your style edit',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tell us what you are looking for and we will tailor the next recommendation.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(title),
                        content: const Text(
                          'Your request has been added to your Veylora style plan.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Get started'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _securityCodeController = TextEditingController();
  String _paymentMethod = 'Card';
  bool _isComplete = false;

  @override
  void dispose() {
    _amountController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _securityCodeController.dispose();
    super.dispose();
  }

  void _submitPayment() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment complete')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.check,
                    size: 36,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Payment received',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  '₱${_amountController.text} was paid with $_paymentMethod.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Veylora'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Make a payment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              'Settle your Veylora balance.',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Payments are processed securely and your receipt will be shown here.',
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₱ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount <= 0) {
                  return 'Enter an amount greater than zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment method',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Card',
                  child: Text('Debit or credit card'),
                ),
                DropdownMenuItem(
                  value: 'Bank transfer',
                  child: Text('Bank transfer'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _paymentMethod = value ?? 'Card'),
            ),
            if (_paymentMethod == 'Card') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Card number',
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.replaceAll(' ', '').length < 12)
                    ? 'Enter a valid card number'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry',
                        hintText: 'MM/YY',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Required'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _securityCodeController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Security code',
                        hintText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().length < 3)
                          ? 'Required'
                          : null,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submitPayment,
              icon: const Icon(Icons.lock_outline),
              label: const Text('Pay now'),
            ),
          ],
        ),
      ),
    );
  }
}
