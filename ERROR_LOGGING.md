# BITOO Error Handling & Logging Strategy

---

##  Error Handling Architecture

```
┌──────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                    │
│                                                        │
│  Widgets consume AsyncValue<T> from Riverpod           │
│  Each widget handles: data | loading | error | empty   │
│                                                        │
│  Riverpod catches all async exceptions                 │
│  ErrorWidget shown to user with retry option           │
└──────────────────────┬───────────────────────────────┘
                       │ Resource<T>
┌──────────────────────▼───────────────────────────────┐
│                   DOMAIN LAYER                        │
│                                                        │
│  UseCases return Resource<T> (Success | Failure)       │
│  No exception handling in domain (pure Dart)           │
└──────────────────────┬───────────────────────────────┘
                       │ Resource<T>
┌──────────────────────▼───────────────────────────────┐
│                    DATA LAYER                          │
│                                                        │
│  Repositories catch exceptions → map to Failure        │
│  DataSources throw typed exceptions                    │
│                                                        │
│  try {                                                  │
│    final response = await dio.get(...);                 │
│    return Success(response);                            │
│  } on DioException catch (e) {                          │
│    return Failure(_mapDioError(e));                     │
│  } on CacheException catch (e) {                        │
│    return Failure(CacheFailure(e.message));             │
│  }                                                      │
└──────────────────────────────────────────────────────┘
```

##  Error Hierarchy

```
FailureReason (sealed)
├── NetworkFailure
│   ├── statusCode: int?
│   └── message: String?
├── ServerFailure
│   ├── statusCode: int
│   ├── message: String
│   └── errors: Map<String, List<String>>?
├── UnauthorizedFailure
├── CacheFailure
│   └── message: String
├── ValidationFailure
│   ├── message: String
│   └── fieldErrors: Map<String, String>?
├── PermissionFailure
│   └── permission: String
├── StorageFailure
│   └── message: String
├── AudioFailure
│   └── message: String
├── DownloadFailure
│   ├── message: String
│   └── taskId: String
└── UnknownFailure
    ├── message: String
    └── exception: Object?
```

##  User-Facing Error Mapping

```dart
extension FailureMessage on FailureReason {
  String get userMessage => switch (this) {
        NetworkFailure() => 'Check your internet connection and try again',
        ServerFailure(:final message) => message,
        UnauthorizedFailure() => 'Session expired. Please sign in again.',
        CacheFailure() => 'Something went wrong. Please try again.',
        ValidationFailure(:final message) => message,
        PermissionFailure(:final permission) =>
          'Allow access to $permission in Settings',
        StorageFailure() => 'Not enough storage space',
        AudioFailure(:final message) => message,
        DownloadFailure(:final message) => message,
        UnknownFailure() => 'Something unexpected happened. Please try again.',
      };
}
```

##  Global Error Handler (Uncaught Exceptions)

```dart
// lib/core/errors/error_handler.dart

class ErrorHandler {
  ErrorHandler({
    required LoggerService logger,
    required CrashlyticsService crashlytics,
  })  : _logger = logger,
        _crashlytics = crashlytics;

  final LoggerService _logger;
  final CrashlyticsService _crashlytics;

  void handleException(Object exception, StackTrace stackTrace) {
    _logger.error(exception.toString(), stackTrace);
    _crashlytics.recordError(exception, stackTrace);
  }

  Future<void> runGuarded(Future<void> Function() callback) async {
    try {
      await callback();
    } catch (e, s) {
      handleException(e, s);
    }
  }
}

// main.dart
void main() {
  runZonedGuarded(() async {
    // ...
    FlutterError.onError = (details) {
      errorHandler.handleException(details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      errorHandler.handleException(error, stack);
      return true;
    };
    // ...
  }, (error, stack) {
    errorHandler.handleException(error, stack);
  });
}
```

---

##  Logging Strategy

### Log Levels

| Level | Usage | Color |
|-------|-------|-------|
| `verbose` | Detailed debug info (development only) | Gray |
| `debug` | Development diagnostics | Blue |
| `info` | Business events (sign in, playback start) | Green |
| `warning` | Recoverable issues (retry, fallback to cache) | Yellow |
| `error` | Unrecoverable errors (API 500, crash) | Red |
| `wtf` | What a Terrible Failure (assertion failures) | Magenta |

### Log Format

```
[2026-07-03 14:30:00.123] [INFO] [AuthRepository] - User signed in: user_id=abc123
[2026-07-03 14:30:01.456] [ERROR] [PlayerService] - Playback failed: track_id=xyz789 | DioException: connection timeout
```

### Logger Service Interface

```dart
abstract class LoggerService {
  void verbose(String message, {Map<String, dynamic>? tags});
  void debug(String message, {Map<String, dynamic>? tags});
  void info(String message, {Map<String, dynamic>? tags});
  void warning(String message, {Map<String, dynamic>? tags, Object? exception});
  void error(String message, [Object? exception, StackTrace? stackTrace]);
  void wtf(String message, [Object? exception, StackTrace? stackTrace]);
}

class LoggerServiceImpl implements LoggerService {
  final _logger = Logger(filter: ProductionFilter());

  @override
  void info(String message, {Map<String, dynamic>? tags}) {
    _logger.info('$message ${_formatTags(tags)}');
  }

  @override
  void error(String message, [Object? exception, StackTrace? stackTrace]) {
    _logger.severe('$message | $exception');
    if (stackTrace != null) _logger.severe(stackTrace.toString());
  }

  String _formatTags(Map<String, dynamic>? tags) {
    if (tags == null || tags.isEmpty) return '';
    return '| ${tags.entries.map((e) => '${e.key}=${e.value}').join(' ')}';
  }
}
```

### Usage Rules

1. Never log PII (email, name, device ID) — use anonymized IDs
2. Always include context tags: `{userId: trackId: feature:}`
3. Error logs must always include exception and stack trace
4. Warning logs when fallback to cache occurs
5. Info logs for key business events (sign in, sign out, playback start,
   download complete, playlist created)
