# BITOO Dependency Injection Strategy

---

##  Philosophy

BITOO uses **Riverpod** as the single DI container. No `GetIt`, no `Provider.of`.
Riverpod provides compile-time safety, testability, and fine-grained rebuild control.

##  Provider Categories

```
┌─────────────────────────────────────────────────────┐
│                   PROVIDER TIERS                      │
├─────────────────────────────────────────────────────┤
│  Tier 1: Core Infrastructure Providers               │
│  ─────────────────────────────────────────────────── │
│  dioClientProvider           → Provider<Dio>          │
│  hiveProvider                → Provider<HiveInterface>│
│  driftDatabaseProvider       → Provider<AppDatabase>  │
│  secureStorageProvider       → Provider<FlutterSecureStorage>│
│  connectivityProvider        → StreamProvider<bool>   │
│  loggerProvider              → Provider<LoggerService>│
│  analyticsProvider           → Provider<AnalyticsService>│
│  cacheManagerProvider        → Provider<CacheManager> │
│  networkInfoProvider         → Provider<NetworkInfo>  │
├─────────────────────────────────────────────────────┤
│  Tier 2: Data Source Providers                       │
│  ─────────────────────────────────────────────────── │
│  authRemoteDataSource        → Provider<AuthRemoteDataSource>│
│  authLocalDataSource         → Provider<AuthLocalDataSource>│
│  homeRemoteDataSource        → Provider<HomeRemoteDataSource>│
│  ... (one per feature's data sources)                │
├─────────────────────────────────────────────────────┤
│  Tier 3: Repository Providers                        │
│  ─────────────────────────────────────────────────── │
│  authRepositoryProvider      → Provider<AuthRepository>│
│  homeRepositoryProvider      → Provider<HomeRepository>│
│  ... (one per feature)                               │
├─────────────────────────────────────────────────────┤
│  Tier 4: UseCase Providers                           │
│  ─────────────────────────────────────────────────── │
│  signInUseCaseProvider       → Provider<SignIn>       │
│  getHomeFeedUseCaseProvider  → Provider<GetHomeFeed>  │
│  ... (one per use case)                              │
├─────────────────────────────────────────────────────┤
│  Tier 5: Feature State Providers                     │
│  ─────────────────────────────────────────────────── │
│  authProvider                → AsyncNotifier<AuthState>│
│  homeFeedProvider            → AsyncNotifier<HomeFeed>│
│  ... (one per feature)                               │
└─────────────────────────────────────────────────────┘
```

##  Provider Registration Pattern

All providers are defined in two locations:

1. **`lib/core/di/core_providers.dart`** — Tier 1 infrastructure providers
2. **`lib/features/{feature}/presentation/providers/`** — Tier 2-5 per feature

```dart
// lib/core/di/core_providers.dart

// Dio client with all interceptors
final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ref.read(envConfigProvider).apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.addAll([
    AuthInterceptor(ref),
    LoggingInterceptor(ref),
    CacheInterceptor(ref),
    RetryInterceptor(ref),
    ConnectivityInterceptor(ref),
    HeaderInterceptor(ref),
  ]);

  return dio;
});

// Environment config
final envConfigProvider = Provider<EnvConfig>((ref) {
  return EnvConfig.fromEnvironment();
});

// Network info
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(DataConnectionChecker());
});

// Logger
final loggerProvider = Provider<LoggerService>((ref) {
  return LoggerServiceImpl();
});

// Analytics
final analyticsProvider = Provider<AnalyticsService>((ref) {
  return MixpanelAnalyticsService(token: ref.read(envConfigProvider).mixpanelToken);
});

// Secure storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Hive
final hiveProvider = Provider<HiveInterface>((ref) {
  return Hive;
});

// Drift database
final driftDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Cache manager
final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager(
    memoryCache: MemoryCache(maxSize: 50),
    diskCache: DiskCache(ref.read(hiveProvider)),
  );
});
```

```dart
// lib/features/auth/presentation/providers/auth_provider.dart

// Data sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(dio: ref.read(dioClientProvider));
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(
    secureStorage: ref.read(secureStorageProvider),
    hive: ref.read(hiveProvider),
  );
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localDataSource: ref.read(authLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// UseCases
final signInUseCaseProvider = Provider<SignIn>((ref) {
  return SignIn(repository: ref.read(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUp>((ref) {
  return SignUp(repository: ref.read(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOut>((ref) {
  return SignOut(repository: ref.read(authRepositoryProvider));
});

// Feature state
@riverpod
class AuthState extends _$AuthState {
  @override
  Future<User?> build() async {
    final useCase = ref.watch(getCurrentUserUseCaseProvider);
    final result = await useCase();
    return result.fold((_) => null, (user) => user);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    final useCase = ref.read(signInUseCaseProvider);
    final result = await useCase(email, password);
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (user) => AsyncData(user),
    );
  }

  Future<void> signOut() async {
    await ref.read(signOutUseCaseProvider).call();
    state = const AsyncData(null);
  }
}
```

##  Dependency Graph Validation

At app startup, validate the entire dependency graph:

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register all Hive adapters
  Hive.registerAdapter(UserModelAdapter());

  // Validate DI graph (fails fast on missing deps)
  final container = ProviderContainer();
  try {
    container.read(dioClientProvider);  // Triggers all transitive deps
  } catch (e) {
    Logger().severe('DI graph validation failed: $e');
    rethrow;
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: const BitooApp(),
  ));
}
```

##  Testing with Riverpod Overrides

```dart
// test/features/auth/auth_provider_test.dart
void main() {
  test('signIn returns user on success', () async {
    final mockRepo = MockAuthRepository();
    when(() => mockRepo.signIn(any(), any()))
        .thenAnswer((_) async => Success(User(id: '1', email: 'test@test.com')));

    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(mockRepo),
    ]);

    final authState = container.read(authStateProvider.notifier);
    await authState.signIn('test@test.com', 'password');

    expect(container.read(authStateProvider).value?.email, 'test@test.com');
  });
}
```
