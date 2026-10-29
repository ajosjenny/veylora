# Veylora

Veylora is a Flutter wardrobe and styling app backed by a small local HTTP API.

## Run the API

From the project root:

```powershell
cd api_server
dart run bin/server.dart
```

The API listens on `http://localhost:8080`.

Available endpoints:

- `GET /api/health`
- `GET /api/catalog`
- `GET /api/products`
- `GET /api/clothing`
- `GET /api/services`
- `POST /api/payments`
- `GET /api/datasets`
- `POST /api/datasets`
- `GET /api/datasets/{id}`
- `PUT /api/datasets/{id}`
- `DELETE /api/datasets/{id}`

The Flutter app fetches featured products from [Fake Store API](https://fakestoreapi.com/products) and loads style services from the local `/api/catalog` endpoint. If either request fails, the dashboard falls back to its local catalog.

The local API's clothing catalog is stored in `api_server/data/clothing.json`. Edit that file and restart the API to update the products returned by its `/api/products` endpoint.

Open **Data Catalog** from the navigation drawer to search, inspect, add, edit, or delete dataset metadata. The catalog is seeded from `api_server/data/datasets.json`; changes made in the app are saved to that file by the API.

`VeyloraApi` provides `get`, `post`, `put`, and `delete` methods for making JSON API requests. Each takes a path relative to the configured API base URL and returns the raw HTTP response:

```dart
final api = VeyloraApi();
final response = await api.put('items/123', body: {'name': 'New name'});
```

The API persists catalog entries as metadata; it does not expose or modify the contents of the sources listed in each entry.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
