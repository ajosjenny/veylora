import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:veylora/codes/data_catalog_page.dart';
import 'package:veylora/services/veylora_api.dart';

void main() {
  testWidgets('loads data sources, searches, and shows source details', (
    tester,
  ) async {
    final datasets = [
      {
        'id': 'services',
        'name': 'Style services',
        'description': 'Styling services offered in the app.',
        'category': 'Services',
        'source': 'GET /api/services',
        'format': 'JSON',
        'updatedAt': '2026-10-27T00:00:00.000Z',
      },
      {
        'id': 'payments',
        'name': 'Payment transactions',
        'description': 'Payment requests and confirmations.',
        'category': 'Commerce',
        'source': 'POST /api/payments',
        'format': 'JSON',
        'updatedAt': '2026-10-27T00:00:00.000Z',
      },
    ];
    final api = VeyloraApi(
      client: MockClient((_) async => httpResponse({'datasets': datasets})),
      baseUrl: 'https://example.com/api',
    );

    await tester.pumpWidget(MaterialApp(home: DataCatalogPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('Style services'), findsOneWidget);
    expect(find.text('Payment transactions'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'payments');
    await tester.pump();
    expect(find.text('Payment transactions'), findsOneWidget);
    expect(find.text('Style services'), findsNothing);

    await tester.tap(find.text('Payment transactions'));
    await tester.pumpAndSettle();
    expect(find.text('POST /api/payments'), findsNWidgets(2));
    expect(find.text('Payment requests and confirmations.'), findsNWidgets(2));
  });
}

http.Response httpResponse(Object body) => http.Response(jsonEncode(body), 200);
