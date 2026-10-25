// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_couchdb/otel_couchdb.dart';

/// Traces Couchdb calls with OpenTelemetry.
///
/// `otel_couchdb` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Couchdb call in
/// [tracedCouchDB]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'couchdb-example');

  // Traces a Couchdb call.
  final couchDBId = await tracedCouchDB<String>(
    operation: 'create',
    invoke: () async {
      // Make the Couchdb call here, then report what it returned.
      const id = 'couchdb_8f3a2c';
      return const CouchDBCallResult(
          value: id,
          result: CouchDBResult(
              database: 'example',
              documentId: 'document_8f3a2c',
              revision: 'example',
              designDoc: 'example',
              viewName: 'example',
              rowsAffected: 1,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedCouchDB create returned $couchDBId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutCouchDBInstrumentationAsync.
  await runWithoutCouchDBInstrumentationAsync(
    () => tracedCouchDB<String>(
      operation: 'create',
      invoke: () async {
        const id = 'couchdb_8f3a2c';
        return const CouchDBCallResult(
            value: id,
            result: CouchDBResult(
                database: 'example',
                documentId: 'document_8f3a2c',
                revision: 'example',
                designDoc: 'example',
                viewName: 'example',
                rowsAffected: 1,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
