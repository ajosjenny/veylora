import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    required this.color,
    this.description = '',
    this.imageUrl,
    this.currencySymbol = r'$',
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final String icon;
  final int color;
  final String description;
  final String? imageUrl;
  final String currencySymbol;

  factory CatalogProduct.fromJson(Map<String, dynamic> json) {
    return CatalogProduct(
      id: json['id'].toString(),
      name: (json['title'] ?? json['name']) as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      icon: json['icon'] as String? ?? 'checkroom',
      color: json['color'] as int? ?? 0xFFE7D5C4,
      description: json['description'] as String? ?? '',
      imageUrl: json['image'] as String? ?? json['imageUrl'] as String?,
    );
  }
}

class CatalogService {
  const CatalogService({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final String icon;

  factory CatalogService.fromJson(Map<String, dynamic> json) {
    return CatalogService(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
    );
  }
}

class CatalogResponse {
  const CatalogResponse({required this.products, required this.services});

  final List<CatalogProduct> products;
  final List<CatalogService> services;

  factory CatalogResponse.fromJson(Map<String, dynamic> json) {
    return CatalogResponse(
      products: (json['products'] as List<dynamic>)
          .map((item) => CatalogProduct.fromJson(item as Map<String, dynamic>))
          .toList(),
      services: (json['services'] as List<dynamic>)
          .map((item) => CatalogService.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CatalogDataset {
  const CatalogDataset({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.source,
    required this.format,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final String source;
  final String format;
  final DateTime updatedAt;

  factory CatalogDataset.fromJson(Map<String, dynamic> json) {
    return CatalogDataset(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      source: json['source'] as String,
      format: json['format'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class VeyloraApi {
  static final Uri _fakeStoreProductsUri = Uri.parse(
    'https://fakestoreapi.com/products',
  );

  VeyloraApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? _defaultBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  static String get _defaultBaseUrl {
    final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    return 'http://$host:8080/api';
  }

  Future<http.Response> get(String path, {Map<String, String>? headers}) {
    return _send('GET', path, headers: headers);
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) {
    return _send('POST', path, body: body, headers: headers);
  }

  Future<http.Response> put(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) {
    return _send('PUT', path, body: body, headers: headers);
  }

  Future<http.Response> delete(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) {
    return _send('DELETE', path, body: body, headers: headers);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final baseUrl = _baseUrl.endsWith('/') ? _baseUrl : '$_baseUrl/';
    final uri = Uri.parse(
      baseUrl,
    ).resolve(path.replaceFirst(RegExp(r'^/+'), ''));
    final requestHeaders = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      ...?headers,
    };
    final encodedBody = body == null ? null : jsonEncode(body);

    return switch (method) {
      'GET' => _client.get(uri, headers: requestHeaders),
      'POST' => _client.post(uri, headers: requestHeaders, body: encodedBody),
      'PUT' => _client.put(uri, headers: requestHeaders, body: encodedBody),
      'DELETE' => _client.delete(
        uri,
        headers: requestHeaders,
        body: encodedBody,
      ),
      _ => throw ArgumentError.value(
        method,
        'method',
        'Unsupported HTTP method',
      ),
    };
  }

  Future<CatalogResponse> fetchCatalog() async {
    final catalogResponseFuture = get('catalog');
    final productsFuture = fetchProducts();
    final catalogResponse = await catalogResponseFuture;
    final products = await productsFuture;
    if (catalogResponse.statusCode != 200) {
      throw Exception('Catalog request failed: ${catalogResponse.statusCode}');
    }
    final catalog = CatalogResponse.fromJson(
      jsonDecode(catalogResponse.body) as Map<String, dynamic>,
    );
    return CatalogResponse(products: products, services: catalog.services);
  }

  Future<List<CatalogProduct>> fetchProducts() async {
    final response = await _client.get(
      _fakeStoreProductsUri,
      headers: const {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Product request failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => CatalogProduct.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> createPayment({
    required double amount,
    required String paymentMethod,
  }) async {
    final response = await post(
      'payments',
      body: {'amount': amount, 'paymentMethod': paymentMethod},
    );
    if (response.statusCode != 200) {
      throw Exception('Payment request failed: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<CatalogDataset>> fetchDatasets() async {
    final response = await get('datasets');
    _requireStatus(response, 200, 'Load data catalog');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['datasets'] as List<dynamic>)
        .map((item) => CatalogDataset.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CatalogDataset> createDataset({
    required String name,
    required String description,
    required String category,
    required String source,
    required String format,
  }) async {
    final response = await post(
      'datasets',
      body: {
        'name': name,
        'description': description,
        'category': category,
        'source': source,
        'format': format,
      },
    );
    _requireStatus(response, 201, 'Create data source');
    return CatalogDataset.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<CatalogDataset> updateDataset({
    required String id,
    required String name,
    required String description,
    required String category,
    required String source,
    required String format,
  }) async {
    final response = await put(
      'datasets/${Uri.encodeComponent(id)}',
      body: {
        'name': name,
        'description': description,
        'category': category,
        'source': source,
        'format': format,
      },
    );
    _requireStatus(response, 200, 'Update data source');
    return CatalogDataset.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> deleteDataset(String id) async {
    final response = await delete('datasets/${Uri.encodeComponent(id)}');
    _requireStatus(response, 204, 'Delete data source');
  }

  void _requireStatus(http.Response response, int expected, String action) {
    if (response.statusCode != expected) {
      var detail = '';
      if (response.body.isNotEmpty) {
        try {
          final body = jsonDecode(response.body);
          if (body is Map<String, dynamic> && body['error'] is String) {
            detail = ': ${body['error']}';
          }
        } on FormatException {
          detail = ': ${response.body}';
        }
      }
      throw Exception('$action failed (${response.statusCode})$detail');
    }
  }
}
