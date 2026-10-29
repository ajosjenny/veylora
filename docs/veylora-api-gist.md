# Veylora API and Featured Products

Veylora is a Flutter wardrobe app backed by a local Dart HTTP API.

## Start the API

```powershell
cd api_server
dart run bin/server.dart
```

The API is available at `http://localhost:8080`.

## Product endpoints

```text
GET /api/products
GET /api/catalog
GET /api/clothing
```

Product data is stored in `api_server/data/clothing.json`. Restart the API after editing the JSON file.

## Data catalog endpoints

The mobile app's Data Catalog lists metadata about available data sources. Entries are stored in `api_server/data/datasets.json`.

```text
GET    /api/datasets
POST   /api/datasets
GET    /api/datasets/{id}
PUT    /api/datasets/{id}
DELETE /api/datasets/{id}
```

Create and update requests accept JSON with `name`, `description`, `category`, `source`, and `format` fields. The API sets the entry ID and `updatedAt` timestamp.

## Featured products

The Flutter dashboard displays featured products from `GET /api/catalog`. Each product card and the `View collection` action opens the full `Featured products` collection page.

## Payment endpoint

```text
POST /api/payments
Content-Type: application/json

{"amount":49.99,"paymentMethod":"card"}
```

The local API returns a payment confirmation response. A production app should connect this flow to a real payment processor.