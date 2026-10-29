import 'dart:convert';
import 'dart:io';

late final List<Map<String, dynamic>> products;
late final List<Map<String, dynamic>> clothing;

const clothingGistUrl =
    'https://gist.githubusercontent.com/ajosjenny/66f6e27fff910a3bdda79957bb9bb9ea/raw/4335e47a6b2e615018dcc318b7d3d5c8b6c1cd72/cloth.json';

const services = [
  {
    'id': 'personal-color-guide',
    'name': 'Personal color guide',
    'description': 'Find colors that work with the pieces you already love.',
    'icon': 'palette',
  },
  {
    'id': 'style-consultation',
    'name': 'Style consultation',
    'description': 'Get recommendations shaped around your taste and routine.',
    'icon': 'support_agent',
  },
  {
    'id': 'curated-shopping',
    'name': 'Curated shopping',
    'description': 'Discover thoughtful additions for your everyday rotation.',
    'icon': 'shopping_bag',
  },
];

Future<void> main() async {
  clothing = await _loadClothing();
  products = clothing.map(_toProduct).toList();

  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  stdout.writeln('Veylora API listening on http://localhost:${server.port}');

  await for (final request in server) {
    _addCorsHeaders(request.response);

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      continue;
    }

    try {
      await _handleRequest(request);
    } catch (error) {
      request.response.statusCode = HttpStatus.internalServerError;
      _writeJson(request.response, {'error': error.toString()});
    }
  }
}

Future<List<Map<String, dynamic>>> _loadClothing() async {
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(clothingGistUrl));
    final response = await request.close();
    if (response.statusCode == HttpStatus.ok) {
      final body = await utf8.decoder.bind(response).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      return (json['clothing'] as List<dynamic>).cast<Map<String, dynamic>>();
    }
  } catch (_) {
    // Fall back to the checked-in catalog when the gist is unavailable.
  }

  final clothingFile = File('data/clothing.json');
  final clothingJson =
      jsonDecode(await clothingFile.readAsString()) as Map<String, dynamic>;
  return (clothingJson['clothing'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
}

Future<void> _handleRequest(HttpRequest request) async {
  final path = request.uri.path;

  if (request.method == 'GET' && path == '/') {
    _writeJson(request.response, {
      'service': 'Veylora API',
      'status': 'running',
      'endpoints': {
        'health': 'GET /api/health',
        'catalog': 'GET /api/catalog',
        'products': 'GET /api/products',
        'clothing': 'GET /api/clothing',
        'services': 'GET /api/services',
        'payments': 'POST /api/payments',
        'datasets':
            'GET, POST /api/datasets; GET, PUT, DELETE /api/datasets/{id}',
      },
    });
    return;
  }

  if (request.method == 'GET' && path == '/api/health') {
    _writeJson(request.response, {'status': 'ok', 'service': 'veylora-api'});
    return;
  }

  if (request.method == 'GET' && path == '/api/catalog') {
    _writeJson(request.response, {'products': products, 'services': services});
    return;
  }

  if (request.method == 'GET' && path == '/api/products') {
    _writeJson(request.response, {'products': products});
    return;
  }

  if (request.method == 'GET' && path == '/api/clothing') {
    _writeJson(request.response, {'clothing': clothing});
    return;
  }

  if (request.method == 'GET' && path == '/api/services') {
    _writeJson(request.response, {'services': services});
    return;
  }

  if (path == '/api/datasets' || path.startsWith('/api/datasets/')) {
    await _handleDatasetRequest(request);
    return;
  }

  if (request.method == 'POST' && path == '/api/payments') {
    final payload = jsonDecode(await utf8.decoder.bind(request).join());
    final amount = payload['amount'];
    if (amount is! num || amount <= 0) {
      request.response.statusCode = HttpStatus.badRequest;
      _writeJson(request.response, {
        'error': 'Amount must be greater than zero.',
      });
      return;
    }

    _writeJson(request.response, {
      'id': 'pay-${DateTime.now().millisecondsSinceEpoch}',
      'status': 'received',
      'amount': amount,
      'paymentMethod': payload['paymentMethod'] ?? 'card',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
    return;
  }

  request.response.statusCode = HttpStatus.notFound;
  _writeJson(request.response, {'error': 'Route not found.'});
}

Future<void> _handleDatasetRequest(HttpRequest request) async {
  final segments = request.uri.pathSegments;
  final isCollection = segments.length == 2;
  final hasId = segments.length == 3 && segments[2].isNotEmpty;
  if (!isCollection && !hasId) {
    request.response.statusCode = HttpStatus.notFound;
    _writeJson(request.response, {'error': 'Route not found.'});
    return;
  }

  final datasetsFile = File('data/datasets.json');
  final data =
      jsonDecode(await datasetsFile.readAsString()) as Map<String, dynamic>;
  final datasets = (data['datasets'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  if (request.method == 'GET' && isCollection) {
    _writeJson(request.response, {'datasets': datasets});
    return;
  }

  if (request.method == 'GET' && hasId) {
    final index = datasets.indexWhere((item) => item['id'] == segments[2]);
    if (index == -1) {
      request.response.statusCode = HttpStatus.notFound;
      _writeJson(request.response, {'error': 'Data source not found.'});
      return;
    }
    _writeJson(request.response, datasets[index]);
    return;
  }

  if (request.method == 'POST' && isCollection) {
    final payload = await _readDatasetPayload(request);
    if (payload == null) return;
    final validationError = _validateDatasetPayload(payload);
    if (validationError != null) {
      request.response.statusCode = HttpStatus.badRequest;
      _writeJson(request.response, {'error': validationError});
      return;
    }

    final dataset = {
      'id': 'dataset-${DateTime.now().microsecondsSinceEpoch}',
      ..._datasetFields(payload),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
    datasets.add(dataset);
    await _writeDatasets(datasetsFile, datasets);
    request.response.statusCode = HttpStatus.created;
    _writeJson(request.response, dataset);
    return;
  }

  if (request.method == 'PUT' && hasId) {
    final index = datasets.indexWhere((item) => item['id'] == segments[2]);
    if (index == -1) {
      request.response.statusCode = HttpStatus.notFound;
      _writeJson(request.response, {'error': 'Data source not found.'});
      return;
    }
    final payload = await _readDatasetPayload(request);
    if (payload == null) return;
    final validationError = _validateDatasetPayload(payload);
    if (validationError != null) {
      request.response.statusCode = HttpStatus.badRequest;
      _writeJson(request.response, {'error': validationError});
      return;
    }

    final dataset = {
      'id': segments[2],
      ..._datasetFields(payload),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
    datasets[index] = dataset;
    await _writeDatasets(datasetsFile, datasets);
    _writeJson(request.response, dataset);
    return;
  }

  if (request.method == 'DELETE' && hasId) {
    final index = datasets.indexWhere((item) => item['id'] == segments[2]);
    if (index == -1) {
      request.response.statusCode = HttpStatus.notFound;
      _writeJson(request.response, {'error': 'Data source not found.'});
      return;
    }
    datasets.removeAt(index);
    await _writeDatasets(datasetsFile, datasets);
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  request.response.statusCode = HttpStatus.methodNotAllowed;
  _writeJson(request.response, {'error': 'Method not allowed.'});
}

Future<Map<String, dynamic>?> _readDatasetPayload(HttpRequest request) async {
  try {
    final decoded = jsonDecode(await utf8.decoder.bind(request).join());
    if (decoded is Map<String, dynamic>) return decoded;
  } on FormatException {
    // Report malformed request bodies as client errors below.
  }
  request.response.statusCode = HttpStatus.badRequest;
  _writeJson(request.response, {
    'error': 'Request body must be a JSON object.',
  });
  return null;
}

String? _validateDatasetPayload(Map<String, dynamic> payload) {
  const requiredFields = [
    'name',
    'description',
    'category',
    'source',
    'format',
  ];
  for (final field in requiredFields) {
    if (payload[field] is! String ||
        (payload[field] as String).trim().isEmpty) {
      return 'Field "$field" is required.';
    }
  }
  return null;
}

Map<String, dynamic> _datasetFields(Map<String, dynamic> payload) => {
  for (final field in ['name', 'description', 'category', 'source', 'format'])
    field: (payload[field] as String).trim(),
};

Future<void> _writeDatasets(
  File file,
  List<Map<String, dynamic>> datasets,
) async {
  await file.writeAsString(jsonEncode({'datasets': datasets}), flush: true);
}

Map<String, dynamic> _toProduct(Map<String, dynamic> item) {
  final category = item['category'] as String;
  final icon = switch (category) {
    'Outerwear' => 'checkroom',
    'Bottoms' => 'dry_cleaning',
    'Skirts' || 'Dresses' => 'checkroom',
    _ => 'checkroom',
  };

  return {
    'id': 'clothing-${item['id']}',
    'name': item['name'],
    'category': item['category'],
    'price': item['price'],
    'icon': icon,
    'color': _colorFor(item['color'] as String),
    'size': item['size'],
    'stock': item['stock'],
  };
}

int _colorFor(String color) => switch (color) {
  'Black' => 0xFF3A3540,
  'White' => 0xFFF3F0EA,
  'Gray' => 0xFFB8B8B8,
  'Blue' || 'Light Blue' || 'Blue and White' => 0xFFB9C9DB,
  'Brown' => 0xFFB79B86,
  'Pink' => 0xFFE9B9C7,
  'Beige' || 'Cream' || 'Khaki' => 0xFFE4D4BC,
  'Green' => 0xFFB6C7AE,
  'Red' => 0xFFD59595,
  'Floral' => 0xFFE6C2B8,
  _ => 0xFFE0D8D0,
};

void _addCorsHeaders(HttpResponse response) {
  response.headers
    ..set('Access-Control-Allow-Origin', '*')
    ..set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
    ..set('Access-Control-Allow-Headers', 'Content-Type');
}

void _writeJson(HttpResponse response, Object body) {
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(body));
  response.close();
}
