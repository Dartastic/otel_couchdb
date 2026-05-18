// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_couchdb/otel_couchdb.dart';
import 'package:test/test.dart';

void main() {
  group('otel_couchdb', () {
    test('suppression toggles in zone', () async {
      expect(couchDBInstrumentationSuppressed(), isFalse);
      await runWithoutCouchDBInstrumentationAsync(() async {
        expect(couchDBInstrumentationSuppressed(), isTrue);
      });
      expect(couchDBInstrumentationSuppressed(), isFalse);
    });

    test('CouchDBResult fields default null', () {
      const r = CouchDBResult();
      expect(r.statusCode, isNull);
    });
  });
}
