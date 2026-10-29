import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:veylora/services/veylora_api.dart';

void main() {
  test('supports GET, POST, PUT, and DELETE requests', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      return http.Response('', 204);
    });
    final api = VeyloraApi(client: client, baseUrl: 'https://example.com/api');

    await api.get('/items?active=true');
    await api.post('items', body: {'name': 'Coat'});
    await api.put('/items/1', body: {'name': 'Updated coat'});
    await api.delete('items/1');

    expect(requests.map((request) => request.method), [
      'GET',
      'POST',
      'PUT',
      'DELETE',
    ]);
    expect(requests.map((request) => request.url.toString()), [
      'https://example.com/api/items?active=true',
      'https://example.com/api/items',
      'https://example.com/api/items/1',
      'https://example.com/api/items/1',
    ]);
    expect(requests[0].headers['accept'], 'application/json');
    expect(requests[1].headers['content-type'], 'application/json');
    expect(jsonDecode(requests[1].body), {'name': 'Coat'});
    expect(requests[2].headers['content-type'], 'application/json');
    expect(jsonDecode(requests[2].body), {'name': 'Updated coat'});
    expect(requests[3].body, isEmpty);
  });

  test('supports data catalog CRUD operations', () async {
    final requests = <http.Request>[];
    final dataset = {
      'id': 'dataset-1',
      'name': 'Clothing inventory',
      'description': 'Wardrobe inventory data.',
      'category': 'Wardrobe',
      'source': 'GET /api/clothing',
      'format': 'JSON',
      'updatedAt': '2026-10-27T00:00:00.000Z',
    };
    final updatedDataset = {...dataset, 'name': 'Updated inventory'};
    final client = MockClient((request) async {
      requests.add(request);
      if (request.method == 'GET') {
        return http.Response(jsonEncode({'datasets': [dataset]}), 200);
      }
      if (request.method == 'POST') {
        return http.Response(jsonEncode(dataset), 201);
      }
      if (request.method == 'PUT') {
        return http.Response(jsonEncode(updatedDataset), 200);
      }
      return http.Response('', 204);
    });
    final api = VeyloraApi(client: client, baseUrl: 'https://example.com/api');

    final datasets = await api.fetchDatasets();
    final created = await api.createDataset(
      name: 'Clothing inventory',
      description: 'Wardrobe inventory data.',
      category: 'Wardrobe',
      source: 'GET /api/clothing',
      format: 'JSON',
    );
    final updated = await api.updateDataset(
      id: 'dataset-1',
      name: 'Updated inventory',
      description: 'Wardrobe inventory data.',
      category: 'Wardrobe',
      source: 'GET /api/clothing',
      format: 'JSON',
    );
    await api.deleteDataset('dataset-1');

    expect(datasets.single.name, 'Clothing inventory');
    expect(created.id, 'dataset-1');
    expect(updated.name, 'Updated inventory');
    expect(requests.map((request) => request.method), [
      'GET',
      'POST',
      'PUT',
      'DELETE',
    ]);
    expect(requests.map((request) => request.url.path), [
      '/api/datasets',
      '/api/datasets',
      '/api/datasets/dataset-1',
      '/api/datasets/dataset-1',
    ]);
    expect(jsonDecode(requests[1].body)['name'], 'Clothing inventory');
    expect(jsonDecode(requests[2].body)['name'], 'Updated inventory');
  });

  test('fetches Fake Store products and preserves local services', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      if (request.url.host == 'fakestoreapi.com') {
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'title': 'Backpack',
              'price': 109.95,
              'description': 'A durable backpack.',
              'category': "men's clothing",
              'image': 'https://example.com/backpack.png',
              'rating': {'rate': 3.9, 'count': 120},
            },
          ]),
          200,
        );
      }
      return http.Response(
        jsonEncode({
          'products': [],
          'services': [
            {
              'id': 'styling',
              'name': 'Styling',
              'description': 'Style consultation.',
              'icon': 'palette',
            },
          ],
        }),
        200,
      );
    });
    final api = VeyloraApi(
      client: client,
      baseUrl: 'https://example.com/api',
    );

    final catalog = await api.fetchCatalog();

    expect(requests, hasLength(2));
    expect(
      requests.map((request) => request.url.toString()),
      containsAll([
        'https://example.com/api/catalog',
        'https://fakestoreapi.com/products',
      ]),
    );
    expect(catalog.products, hasLength(1));
    expect(catalog.products.single.id, '1');
    expect(catalog.products.single.name, 'Backpack');
    expect(catalog.products.single.price, 109.95);
    expect(catalog.products.single.currencySymbol, '\$');
    expect(catalog.products.single.category, "men's clothing");
    expect(
      catalog.products.single.imageUrl,
      'https://example.com/backpack.png',
    );
    expect(catalog.products.single.description, 'A durable backpack.');
    expect(catalog.services.single.name, 'Styling');
  });
}
