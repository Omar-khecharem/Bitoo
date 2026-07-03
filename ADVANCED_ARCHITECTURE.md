# BITOO Analytics, Offline, Cache, Security, Performance

---

##  1. Analytics Strategy

### Event Naming Convention

```
[domain]_[action]_[context]

Examples:
auth_signin_success
auth_signin_failure
playback_track_start
playback_track_complete
playback_track_skip
playlist_create
playlist_track_add
search_query_submit
download_track_complete
```

### Instrumentation Points

| Category | Events |
|----------|--------|
| **Auth** | `auth_signin_success`, `auth_signin_failure`, `auth_signup_success`, `auth_signout` |
| **Playback** | `playback_track_start`, `playback_track_complete`, `playback_track_skip`, `playback_seek`, `playback_shuffle_toggle`, `playback_repeat_change`, `playback_queue_reorder` |
| **Discovery** | `search_query_submit`, `search_result_tap`, `explore_section_view`, `genre_tap` |
| **Library** | `playlist_create`, `playlist_track_add`, `playlist_track_remove`, `library_item_add`, `library_item_remove` |
| **Social** | `social_share_playlist`, `social_follow_artist` |
| **Settings** | `settings_theme_change`, `settings_equalizer_change`, `settings_quality_change` |
| **Downloads** | `download_track_start`, `download_track_complete`, `download_track_delete` |
| **Performance** | `performance_app_start`, `performance_page_load`, `performance_api_latency` |

### Architecture

```dart
abstract class AnalyticsService {
  void trackEvent(String eventName, {Map<String, Object?>? properties});
  void setUserId(String? userId);
  void setUserProperty(String name, Object? value);
}

// Implementation uses Firebase Analytics + Mixpanel
class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  void trackEvent(String eventName, {Map<String, Object?>? properties}) {
    _analytics.logEvent(name: eventName, parameters: properties);
  }
}
```

---

##  2. Offline Mode Strategy

### Architecture: Offline-First with Queue

```
                    ┌─────────────┐
                    │   Online?   │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │ YES        │ NO         │
              ▼            ▼            │
        ┌──────────┐  ┌──────────┐      │
        │ Network  │  │  Local   │      │
        │  First   │  │   Only   │      │
        └────┬─────┘  └──────────┘      │
             │                          │
        ┌────▼─────┐                   │
        │ Update   │                   │
        │  Local   │                   │
        │  Cache   │                   │
        └──────────┘                   │
                                       │
        ┌──────────────────────────────┘
        │
   ┌────▼─────┐
   │  Return  │
   │  Data    │
   └──────────┘
```

### Sync Strategy

| Operation | Online Behavior | Offline Behavior | Sync on Reconnect |
|-----------|----------------|------------------|-------------------|
| Browse feed | Fetch from API, cache response | Show cached feed | — |
| Search | Fetch from API | Show cached results | — |
| Play track | Stream from network | Play downloaded file | — |
| Create playlist | POST to API | Save locally, queue | POST queued item |
| Add to library | POST to API | Save locally, queue | POST queued item |
| Download track | Download file + metadata | — | — |
| Update profile | PUT to API | Queue for sync | PUT queued change |
| Like track | POST to API | Save locally, queue | POST queued item |

### Queue Implementation

```dart
@freezed
class SyncOperation with _$SyncOperation {
  const factory SyncOperation({
    required String id,
    required SyncAction action,
    required String endpoint,
    required String method,
    required Map<String, dynamic> body,
    required DateTime createdAt,
  }) = _SyncOperation;
}

enum SyncAction { create, update, delete }

class SyncQueue {
  final Box<SyncOperation> _box;

  Future<void> enqueue(SyncOperation operation) async {
    await _box.put(operation.id, operation);
  }

  Future<void> processQueue() async {
    final operations = _box.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    for (final op in operations) {
      try {
        await _executeOperation(op);
        await _box.delete(op.id);
      } catch (e) {
        // Exponential backoff handled by retry interceptor
        break;
      }
    }
  }
}
```

---

##  3. Caching Strategy

### Multi-Tier Cache

```
Layer 1: Memory Cache (LRU)
  - Max 50 entries
  - TTL: 5 minutes
  - Stores: active feed, current search results, album art URLs

Layer 2: Disk Cache (Hive)
  - Type: Persistent key-value
  - TTL: 24 hours (configurable by data type)
  - Stores: feed data, search history, recently played

Layer 3: HTTP Cache (Dio + Isar)
  - Type: HTTP response cache (cache-control headers)
  - Stores: API responses for GET requests

Layer 4: Database (Drift)
  - Type: Relational SQLite
  - Stores: downloaded metadata, playlists, library (authoritative)
```

### Cache Policies

```dart
enum CachePolicy {
  /// Always fetch from network, update cache
  networkFirst,

  /// Return cache first, refresh in background
  cacheFirst,

  /// Only return cache, never fetch
  cacheOnly,

  /// Only fetch from network, never cache
  networkOnly,

  /// Return cache while refreshing in background
  staleWhileRevalidate,
}

class CacheEntry<T> {
  final T data;
  final DateTime cachedAt;
  final DateTime expiresAt;

  bool get isValid => DateTime.now().isBefore(expiresAt);
  bool get isStale => !isValid;
}
```

### CacheManager Implementation

```dart
class CacheManager {
  CacheManager({
    required MemoryCache memoryCache,
    required DiskCache diskCache,
  })  : _memory = memoryCache,
        _disk = diskCache;

  final MemoryCache _memory;
  final DiskCache _disk;

  Future<T?> get<T>(String key) async {
    // 1. Try memory cache
    final memoryResult = _memory.get<T>(key);
    if (memoryResult != null) return memoryResult;

    // 2. Try disk cache
    final diskResult = await _disk.get<T>(key);
    if (diskResult != null) {
      _memory.set(key, diskResult);  // Warm memory cache
      return diskResult;
    }

    return null;
  }

  Future<void> set<T>(String key, T data, {Duration? ttl}) async {
    _memory.set(key, data);
    await _disk.set(key, data, ttl: ttl);
  }

  Future<void> invalidate(String key) async {
    _memory.remove(key);
    await _disk.remove(key);
  }

  Future<void> clear() async {
    _memory.clear();
    await _disk.clear();
  }
}
```

---

##  4. Security Architecture

### Threat Model

| Threat | Mitigation |
|--------|------------|
| API token theft | FlutterSecureStorage (encrypted at rest, KeyChain/KeyStore) |
| Man-in-the-middle | SSL pinning (SHA-256 fingerprint) |
| Reverse engineering | ProGuard/R8 + Flutter obfuscation |
| Local data tampering | HMAC integrity check on Hive boxes |
| Screenshot in background | FLAG_SECURE on sensitive pages |
| Rooted/jailbroken device | Runtime detection + graceful degradation |
| Replay attack | OAuth2 PKCE flow + nonce |
| API key extraction | `--dart-define` at build time, not source code |

### SSL Pinning

```dart
class SslPinningInterceptor extends Interceptor {
  final List<String> _allowedFingerprints = [
    'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',  // Production
  ];

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Certificate validation happens at the socket level via NetworkSecurityPolicy
    handler.next(response);
  }
}

// Android: res/xml/network_security_config.xml
// iOS: Info.plist > NSAppTransportSecurity > NSPinnedDomains
```

### Secure Storage

```dart
class TokenManager {
  TokenManager({required FlutterSecureStorage storage}) : _storage = storage;

  final FlutterSecureStorage _storage;
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens(AuthToken token) async {
    await _storage.write(key: _accessTokenKey, value: token.accessToken);
    await _storage.write(key: _refreshTokenKey, value: token.refreshToken);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
```

### Data Encryption at Rest

```dart
class EncryptionService {
  final Key _key;
  EncryptionService._(this._key);

  static Future<EncryptionService> create() async {
    final key = Key.fromUtf8(await _deriveKey());
    return EncryptionService._(key);
  }

  static Future<String> _deriveKey() async {
    // Use FlutterSecureStorage to store a generated key
    // Derive from device ID + app-specific salt via PBKDF2
  }

  String encrypt(String plaintext) {
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return '${base64.encode(iv.bytes)}:${encrypted.base64}';
  }

  String decrypt(String ciphertext) {
    final parts = ciphertext.split(':');
    final iv = IV.fromBase64(parts[0]);
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    return encrypter.decrypt64(parts[1], iv: iv);
  }
}

// Hive encryption
final encryptedBox = await Hive.openBox('secure', encryptionKey: encryptionKey);
```

---

##  5. Performance Optimizations

### Startup Optimization

| Technique | Implementation |
|-----------|----------------|
| Lazy initialization | Hive boxes opened on first access, not at startup |
| Async main | `WidgetsFlutterBinding.ensureInitialized()` first |
| Deferred loading | `deferred as` for non-critical features |
| Minimal main isolate | Offload JSON parsing to compute isolates |
| Preload cache | Pre-warm Dio DNS + HTTP connection pool |

### Rendering Performance

- Use `const` constructors everywhere
- Minimize rebuilds with `select()` in Riverpod
- Use `ListView.builder` (never `ListView(children: [...])`)
- `RepaintBoundary` for complex widgets (album art)
- Avoid `Opacity` — use `AnimatedOpacity` or `Visibility`
- Avoid clipping where possible
- Use `ImageCache` with `CachedNetworkImage`
- Preload album art: `precacheImage()` in page transitions
- Lazy-load `ScrollController` + `VisibilityDetector` for analytics

### Memory Management

- Dispose controllers in `dispose()` (AnimationController, TextEditingController)
- Cancel HTTP requests on navigation (`CancelToken` in Dio)
- Clear image cache on low memory: `ImageCache().clear()`
- Use `Reassemble` in debug mode to clear caches
- Monitor with `DevTools` memory tab
- Limit concurrent downloads to 3
- Release audio resources when not playing

### Network Optimization

- HTTP/2 with connection multiplexing (Dio)
- Response compression (gzip)
- Pagination: 20 items per page
- Debounced search: 300ms
- Image resizing: request 2x display density width
- Batch API calls where possible
- Prefetch next page: `ScrollController` + 80% threshold

### Build Optimization

```yaml
# build.yaml
targets:
  $default:
    builders:
      source_gen|combining_builder:
        options:
          ignore_for_file:
            - prefer_const_constructors
            - type_literal_in_constant_pattern
      freezed:
        options:
          union_key: type
          fallback_enum: null
```

```groovy
// android/app/build.gradle
android {
    compileSdk 34
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    bundle {
        density { enableSplit true }
        abi { enableSplit true }
        language { enableSplit true }
    }
}
```

### APK Size Reduction Targets

| Asset | Target |
|-------|--------|
| AAB size | < 40 MB |
| Download size | < 30 MB |
| Asset catalog | Compressed WebP for images |
| Fonts | Subset to used characters |
| Native libs | arm64-v8a only for release (or split ABI) |
| Resources | `shrinkResources true` |
| Unused code | R8 full mode |
| Dart code | Tree-shaking (automatic) |
