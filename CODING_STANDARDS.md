# BITOO Coding Standards & Naming Conventions

Enterprise-grade rules for maintainable, predictable, and reviewable code.

---

##  1. Dart & Flutter Style

### 1.1 Language Version

- Dart 3.4+
- Null safety mandatory (sound null safety)
- `sealed` classes for type-safe state hierarchies
- `switch` expressions exhaustively matched
- Pattern matching preferred over `is` checks in multiple branches

### 1.2 Linting (analysis_options.yaml)

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # ── STYLE ──
    - always_declare_return_types
    - annotate_overrides
    - avoid_empty_else
    - avoid_init_to_null
    - avoid_null_checks_in_equality_operators
    - avoid_print
    - avoid_redundant_argument_values
    - avoid_return_types_on_setters
    - avoid_shadowing_type_parameters
    - avoid_single_cascade_in_expression_statements
    - avoid_types_as_parameter_names
    - await_only_futures
    - camel_case_extensions
    - camel_case_types
    - constant_identifier_names
    - curly_braces_in_flow_control_structures
    - directives_ordering
    - empty_catches
    - empty_constructor_bodies
    - empty_statements
    - exhaustive_cases
    - file_names
    - hash_and_equals
    - implementation_imports
    - no_duplicate_case_values
    - no_leading_underscores_for_library_prefixes
    - no_leading_underscores_for_local_identifiers
    - non_constant_identifier_names
    - null_check_on_nullable_type_parameter
    - one_member_abstracts
    - only_throw_errors
    - overridden_fields
    - prefer_adjacent_string_concatenation
    - prefer_collection_literals
    - prefer_conditional_assignment
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_contains
    - prefer_final_fields
    - prefer_final_locals
    - prefer_for_elements_to_map_fromIterable
    - prefer_generic_function_type_aliases
    - prefer_if_elements_to_conditional_expressions
    - prefer_if_null_operators
    - prefer_initializing_formals
    - prefer_inlined_adds
    - prefer_int_literals
    - prefer_interpolation_to_compose_strings
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_is_not_operator
    - prefer_iterable_whereType
    - prefer_null_aware_operators
    - prefer_single_quotes
    - prefer_spread_collections
    - prefer_typing_uninitialized_variables
    - prefer_void_to_null
    - provide_deprecation_message
    - recursive_getters
    - require_trailing_commas
    - sized_box_for_whitespace
    - slash_for_doc_comments
    - sort_child_properties_last
    - sort_constructors_first
    - sort_pub_dependencies
    - sort_unnamed_constructors_first
    - type_init_formals
    - unnecessary_brace_in_string_interps
    - unnecessary_const
    - unnecessary_getters_setters
    - unnecessary_late
    - unnecessary_new
    - unnecessary_null_aware_assignments
    - unnecessary_null_in_if_null_operators
    - unnecessary_nullable_for_final_variable_declarations
    - unnecessary_overrides
    - unnecessary_string_escapes
    - unnecessary_string_interpolations
    - unnecessary_this
    - unrelated_type_equality_checks
    - use_build_context_synchronously
    - use_full_hex_values_for_flutter_colors
    - use_function_type_syntax_for_parameters
    - use_key_in_widget_constructors
    - use_named_constants
    - use_raw_strings
    - use_rethrow_when_possible
    - use_setters_to_change_properties
    - use_string_buffers
    - use_super_parameters
    - use_to_and_as_if_applicable
    - void_checks

dart_code_metrics:
  metrics:
    cyclomatic_complexity: 10
    maximum-nesting-level: 4
    number-of-parameters: 4
    source-lines-of-code: 100
    lines-of-executable-code: 50
    number-of-methods: 10
    number-of-widgets: 15
  rules:
    - avoid-missing-enum-constant-in-map
    - avoid-non-null-assertion
    - avoid-unused-parameters
    - double-literal-format
    - member-ordering:
        alphabetize: false
        order:
          - constructors
          - public-fields
          - private-fields
          - public-getters
          - private-getters
          - public-setters
          - private-setters
          - public-methods
          - private-methods
    - no-boolean-literal-compare
    - no-empty-block
    - no-equal-then-else
    - no-magic-number
    - prefer-conditional-expressions
    - prefer-moving-to-variable
    - prefer-trailing-comma
    - provide-correct-int-to-string-utility
```

---

##  2. Naming Conventions

### 2.1 File Naming

| Element | Convention | Example |
|---------|-----------|---------|
| Dart files | `snake_case` | `auth_repository.dart` |
| Test files | `*_test.dart` | `auth_repository_test.dart` |
| Golden files | `*.golden.png` | `login_page.golden.png` |
| Assets | `snake_case` | `placeholder_album.png` |
| Environment files | `.env.{env}` | `.env.dev` |

### 2.2 Dart Naming

| Element | Convention | Example |
|---------|-----------|---------|
| Packages | `snake_case` | `import 'package:bitoo/core/...'` |
| Libraries | `snake_case` | `library auth_repository;` |
| Classes / Enums / Mixins | `PascalCase` | `class AuthRepository` |
| Type aliases | `PascalCase` | `typedef JsonMap = Map<String, dynamic>;` |
| Extensions | `PascalCase` | `extension ContextExtensions on BuildContext` |
| Constants | `camelCase` | `const defaultPageSize = 20;` |
| `const` with `static` | `camelCase` | `static const maxRetries = 3;` |
| Enum values | `camelCase` | `enum Status { loading, success, failure }` |
| Variables / Parameters | `camelCase` | `final authRepository` |
| Private members | `_camelCase` | `final _dioClient` |
| Booleans | `is`/`has`/`can` prefix | `isLoading`, `hasError`, `canPlay` |
| Functions / Methods | `camelCase` | `Future<Result> fetchData()` |
| Private functions | `_camelCase` | `void _handleResponse()` |
| UseCase classes | verb + noun | `GetHomeFeed`, `SignInUser` |
| Provider variables | `camelCase` + `Provider` suffix | `final authProvider` |

### 2.3 Flutter-Specific

| Element | Convention | Example |
|---------|-----------|---------|
| Widget classes | `PascalCase` | `class LoginPage extends ConsumerStatefulWidget` |
| State classes | `_{WidgetName}State` | `_LoginPageState` |
| Route names | `snake_case` | `static const login = 'login';` |
| Route paths | `kebab-case` | `/auth/login` |
| Provider names | noun + `Provider` | `authProvider`, `homeFeedProvider` |
| Provider suffix | `Provider` | `AuthProvider` (class), `authProvider` (instance) |
| Riverpod providers | `final` + camelCase | `final authProvider = ...` |

### 2.4 File Structure (within a Dart file)

```
1.  File-level doc comment (optional)
2.  Library declaration
3.  Imports (sorted: dart → flutter → package → local)
4.  Export declarations
5.  Part declarations
6.  Top-level constants
7.  Top-level typedefs
8.  Classes (public → protected → private)
9.  Top-level functions
```

---

##  3. Code Organization Rules

### 3.1 Class Member Ordering

```
class ClassName {
  // 1. Static constants
  // 2. Static methods
  // 3. Instance fields (final → non-final)
  // 4. Constructor
  // 5. Constructor.body
  // 6. Overridden methods (build, initState, dispose, etc.)
  // 7. Public methods
  // 8. Private methods
  // 9. Build method (Widgets only, last)
}
```

### 3.2 Widget Structure (ConsumerStatefulWidget)

```dart
class TrackListTile extends ConsumerStatefulWidget {
  const TrackListTile({super.key, required this.track});

  final TrackEntity track;

  @override
  ConsumerState<TrackListTile> createState() => _TrackListTileState();
}

class _TrackListTileState extends ConsumerState<TrackListTile> {
  // 1. Instance fields
  // 2. Lifecycle methods (initState → didChangeDependencies → dispose)
  // 3. Event handlers (private)
  // 4. Helper widgets (private methods returning Widget)
  // 5. build method
}
```

### 3.3 Repository Implementation Pattern

```dart
class TrackRepositoryImpl implements TrackRepository {
  TrackRepositoryImpl({
    required TrackRemoteDataSource remoteDataSource,
    required TrackLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  final TrackRemoteDataSource _remoteDataSource;
  final TrackLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Resource<List<TrackEntity>>> getTracks(String query) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.fetchTracks(query);
        final entities = models.map((m) => m.toEntity()).toList();
        await _localDataSource.cacheTracks(models);
        return Success(entities);
      } catch (e) {
        // Fallback to cache on network error
        return _getCachedTracks(query);
      }
    }
    return _getCachedTracks(query);
  }

  Future<Resource<List<TrackEntity>>> _getCachedTracks(String query) async {
    try {
      final cached = await _localDataSource.getCachedTracks(query);
      if (cached.isEmpty) return Failure(CacheFailure('No cached data'));
      return Success(cached.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Failure(CacheFailure(e.toString()));
    }
  }
}
```

---

##  4. Import Rules

```dart
// ✅ CORRECT — absolute package imports
import 'package:bitoo/core/errors/failures.dart';
import 'package:bitoo/features/auth/domain/repositories/auth_repository.dart';

// ❌ WRONG — relative imports
import '../../../core/errors/failures.dart';

// ✅ CORRECT — within same feature, use relative imports
import '../domain/entities/user.dart';

// ✅ CORRECT — import ordering
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';

// 4. Application packages
import 'package:bitoo/core/errors/failures.dart';

// 5. Relative imports (same feature)
import '../domain/entities/user.dart';
```

**Rule:** Use absolute package imports for cross-feature references.
Use relative imports only within the same feature.

---

##  5. Coding Patterns

### 5.1 Use `sealed` for State Hierarchies

```dart
sealed class PlaybackState {
  const PlaybackState();
}

class Playing extends PlaybackState {
  final TrackEntity track;
  final Duration position;
  const Playing({required this.track, required this.position});
}

class Paused extends PlaybackState {
  final TrackEntity track;
  final Duration position;
  const Paused({required this.track, required this.position});
}

class Stopped extends PlaybackState {
  const Stopped();
}
```

### 5.2 Use Freezed for Data Classes

```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String displayName,
    String? photoUrl,
    @Default(false) bool isPremium,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### 5.3 Use Riverpod with Code Generation

```dart
// Feature provider
@riverpod
class HomeFeed extends _$HomeFeed {
  @override
  Future<List<FeedSection>> build() async {
    final useCase = ref.watch(getHomeFeedUseCaseProvider);
    final result = await useCase();
    return result.fold(
      (failure) => throw failure,
      (data) => data,
    );
  }
}

// Usage in widget
final feedAsync = ref.watch(homeFeedProvider);
feedAsync.when(
  data: (sections) => FeedListView(sections: sections),
  loading: () => const ShimmerLoading(),
  error: (e, _) => ErrorWidget(message: e.toString()),
);
```

### 5.4 UseCase Pattern (Single Responsibility)

```dart
class GetHomeFeed {
  GetHomeFeed({required HomeRepository repository})
      : _repository = repository;

  final HomeRepository _repository;

  Future<Resource<List<FeedSection>>> call() {
    return _repository.getFeed();
  }
}
```

### 5.5 Repository Pattern (Offline-First)

```dart
abstract class HomeRepository {
  Future<Resource<List<FeedSection>>> getFeed();
}

class HomeRepositoryImpl implements HomeRepository {
  // Network-first, cache-fallback, offline-mode
}
```

---

##  6. Error Handling Rules

1. **Never** catch generic `Exception`. Always catch specific types.
2. **Never** `throw` strings. Always throw typed exceptions.
3. **Never** use `print()`. Use the Logger service.
4. All repository methods return `Resource<T>` (Success/Failure).
5. UseCases never catch — they propagate `Resource<T>`.
6. Providers catch and expose `AsyncValue.error`.
7. Widgets handle all states: `data`, `loading`, `error`, `empty`.

---

##  7. Commenting Policy

- **No comments** on self-documenting code.
- **Doc comments (`///`)** only on public API surfaces (repositories, usecases).
- **TODO comments** must include a ticket number: `// TODO(AB-123): ...`
- **No commented-out code** — ever. Delete it.

---

##  8. Widget Constraints

| Rule | Enforcement |
|------|-------------|
| `const` constructors | Mandatory for all widgets |
| `Key` parameter | Always `super.key` |
| No business logic in widgets | Lint rule |
| No direct API calls in widgets | Architecture review |
| No navigation outside providers | Architecture review |
| Max 200 lines per widget file | Code review |
| Max 3 `setState` calls per widget | Code review |
| Prefer `ConsumerWidget` over `ConsumerStatefulWidget` | Code review |
