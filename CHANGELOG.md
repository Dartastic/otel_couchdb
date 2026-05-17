# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedCouchDB<T>(...)` — wraps a otel_couchdb call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutCouchDBInstrumentation()` / `Async()`.
