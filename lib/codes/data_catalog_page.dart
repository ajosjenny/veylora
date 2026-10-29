import 'package:flutter/material.dart';

import '../services/veylora_api.dart';

class DataCatalogPage extends StatefulWidget {
  const DataCatalogPage({this.api, super.key});

  final VeyloraApi? api;

  @override
  State<DataCatalogPage> createState() => _DataCatalogPageState();
}

class _DataCatalogPageState extends State<DataCatalogPage> {
  late final VeyloraApi _api;
  final _searchController = TextEditingController();
  List<CatalogDataset> _datasets = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  List<CatalogDataset> get _filteredDatasets {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _datasets;
    return _datasets.where((dataset) {
      return [
        dataset.name,
        dataset.description,
        dataset.category,
        dataset.source,
        dataset.format,
      ].any((value) => value.toLowerCase().contains(query));
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? VeyloraApi();
    _refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final datasets = await _api.fetchDatasets();
      if (!mounted) return;
      setState(() {
        _datasets = datasets;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addDataset() async {
    final draft = await _showDatasetForm();
    if (draft == null) return;
    try {
      await _api.createDataset(
        name: draft.name,
        description: draft.description,
        category: draft.category,
        source: draft.source,
        format: draft.format,
      );
      await _refresh();
      _showMessage('Data source added.');
    } catch (error) {
      _showMessage('Could not add data source: $error');
    }
  }

  Future<void> _editDataset(CatalogDataset dataset) async {
    final draft = await _showDatasetForm(dataset: dataset);
    if (draft == null) return;
    try {
      await _api.updateDataset(
        id: dataset.id,
        name: draft.name,
        description: draft.description,
        category: draft.category,
        source: draft.source,
        format: draft.format,
      );
      await _refresh();
      _showMessage('Data source updated.');
    } catch (error) {
      _showMessage('Could not update data source: $error');
    }
  }

  Future<void> _deleteDataset(CatalogDataset dataset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete data source?'),
        content: Text('“${dataset.name}” will be removed from the catalog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deleteDataset(dataset.id);
      await _refresh();
      _showMessage('Data source deleted.');
    } catch (error) {
      _showMessage('Could not delete data source: $error');
    }
  }

  Future<_DatasetDraft?> _showDatasetForm({
    CatalogDataset? dataset,
  }) async {
    return showDialog<_DatasetDraft>(
      context: context,
      builder: (context) => _DatasetFormDialog(dataset: dataset),
    );
  }

  void _showDatasetDetails(CatalogDataset dataset) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dataset.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dataset.description),
            const SizedBox(height: 18),
            _detailRow('Category', dataset.category),
            _detailRow('Source', dataset.source),
            _detailRow('Format', dataset.format),
            _detailRow(
              'Last updated',
              MaterialLocalizations.of(context).formatMediumDate(
                dataset.updatedAt.toLocal(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final datasets = _filteredDatasets;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Catalog',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDataset,
        icon: const Icon(Icons.add),
        label: const Text('Add source'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          children: [
            Text(
              'Explore and manage the data behind your Veylora experience.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search data sources',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 14),
            if (_isLoading && _datasets.isEmpty)
              const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && _datasets.isEmpty)
              _buildError()
            else if (datasets.isEmpty)
              _buildEmptyState()
            else ...[
              Text(
                '${datasets.length} ${datasets.length == 1 ? 'data source' : 'data sources'}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              for (final dataset in datasets) _datasetCard(dataset),
            ],
            if (_error != null && _datasets.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Refresh failed: $_error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 44),
          const SizedBox(height: 12),
          const Text('Data catalog unavailable'),
          const SizedBox(height: 4),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44),
      child: Column(
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.storage_outlined : Icons.search_off,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isEmpty
                ? 'No data sources yet'
                : 'No matching data sources',
          ),
          const SizedBox(height: 4),
          Text(
            _searchQuery.isEmpty
                ? 'Add a source to start your catalog.'
                : 'Try a different search term.',
          ),
        ],
      ),
    );
  }

  Widget _datasetCard(CatalogDataset dataset) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDatasetDetails(dataset),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: Icon(
                  Icons.dataset_outlined,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dataset.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dataset.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Chip(
                          label: Text(dataset.category),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        Chip(
                          label: Text(dataset.format),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                    Text(
                      dataset.source,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Data source actions',
                onSelected: (action) {
                  if (action == 'edit') _editDataset(dataset);
                  if (action == 'delete') _deleteDataset(dataset);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatasetDraft {
  const _DatasetDraft({
    required this.name,
    required this.description,
    required this.category,
    required this.source,
    required this.format,
  });

  final String name;
  final String description;
  final String category;
  final String source;
  final String format;
}

class _DatasetFormDialog extends StatefulWidget {
  const _DatasetFormDialog({this.dataset});

  final CatalogDataset? dataset;

  @override
  State<_DatasetFormDialog> createState() => _DatasetFormDialogState();
}

class _DatasetFormDialogState extends State<_DatasetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final dataset = widget.dataset;
    _controllers = {
      'name': TextEditingController(text: dataset?.name ?? ''),
      'description': TextEditingController(text: dataset?.description ?? ''),
      'category': TextEditingController(text: dataset?.category ?? ''),
      'source': TextEditingController(text: dataset?.source ?? ''),
      'format': TextEditingController(text: dataset?.format ?? 'JSON'),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _DatasetDraft(
        name: _controllers['name']!.text.trim(),
        description: _controllers['description']!.text.trim(),
        category: _controllers['category']!.text.trim(),
        source: _controllers['source']!.text.trim(),
        format: _controllers['format']!.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      ('name', 'Name'),
      ('description', 'Description'),
      ('category', 'Category'),
      ('source', 'Source or endpoint'),
      ('format', 'Format'),
    ];
    return AlertDialog(
      title: Text(widget.dataset == null ? 'Add data source' : 'Edit data source'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (key, label) in fields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _controllers[key],
                    maxLines: key == 'description' ? 3 : 1,
                    decoration: InputDecoration(
                      labelText: label,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? '$label is required'
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.dataset == null ? 'Add source' : 'Save'),
        ),
      ],
    );
  }
}
