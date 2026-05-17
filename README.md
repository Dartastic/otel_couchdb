# otel_couchdb

Dartastic OpenTelemetry bridge for CouchDB (document database).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_couchdb/otel_couchdb.dart';

await tracedCouchDB<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return CouchDBCallResult(value: r, result: CouchDBResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutCouchDBInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
