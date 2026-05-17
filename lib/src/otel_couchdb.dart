// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_couchdb_suppression.dart';

class CouchDBResult {
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

class CouchDBCallResult<T> {
  const CouchDBCallResult({required this.value, this.result});
  final T value;
  final CouchDBResult? result;
}

Future<T> tracedCouchDB<T>({
  required String operation,
  required Future<CouchDBCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (couchDBInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_couchdb');
  final span = t.startSpan('couchdb $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('db.system.name', 'couchdb');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.database != null) {
        span.setStringAttribute('db.namespace', res.database!);
      }
      if (res.documentId != null) {
        span.setStringAttribute('couchdb.document.id', res.documentId!);
      }
      if (res.revision != null) {
        span.setStringAttribute('couchdb.revision', res.revision!);
      }
      if (res.designDoc != null) {
        span.setStringAttribute('couchdb.design_doc', res.designDoc!);
      }
      if (res.viewName != null) {
        span.setStringAttribute('couchdb.view', res.viewName!);
      }
      if (res.rowsAffected != null) {
        span.setIntAttribute('db.response.returned_rows', res.rowsAffected!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('couchdb.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'couchdb.error',
        );
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
