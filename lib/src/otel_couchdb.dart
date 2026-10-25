// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_couchdb_suppression.dart';

class CouchDBResult {
  /// Creates a result.
  const CouchDBResult({
    this.database,
    this.documentId,
    this.revision,
    this.designDoc,
    this.viewName,
    this.rowsAffected,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? database;
  final String? documentId;
  final String? revision;
  final String? designDoc;
  final String? viewName;
  final int? rowsAffected;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class CouchDBCallResult<T> {
  /// Creates a call result.
  const CouchDBCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final CouchDBResult? result;
}

Future<T> tracedCouchDB<T>({
  required String operation,
  required Future<CouchDBCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (couchDBInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_couchdb');
  final span = t.startSpan('couchdb $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('db.system.name', 'couchdb')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.database != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('db.namespace', res.database!)]));
      }
      if (res.documentId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('couchdb.document.id', res.documentId!)]));
      }
      if (res.revision != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('couchdb.revision', res.revision!)]));
      }
      if (res.designDoc != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('couchdb.design_doc', res.designDoc!)]));
      }
      if (res.viewName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('couchdb.view', res.viewName!)]));
      }
      if (res.rowsAffected != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('db.response.returned_rows', res.rowsAffected!)
        ]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('couchdb.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'couchdb.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
