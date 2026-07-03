# BITOO Architecture Guide

Enterprise Music Platform — Flutter

---

##  Architecture Philosophy

BITOO follows **Feature-First Clean Architecture** — a hybrid approach combining
the scalability of Clean Architecture with the discoverability of Feature-First
modularization. Every feature is an independent vertical slice that communicates
through well-defined interfaces.

```
┌─────────────────────────────────────────────────┐
│                   PRESENTATION                   │
│  Providers (Riverpod)  →  Pages  →  Widgets      │
├─────────────────────────────────────────────────┤
│                    DOMAIN                        │
│  Entities  ←  Repositories (abstract)  ←  UseCases│
├─────────────────────────────────────────────────┤
│                     DATA                         │
│  Repositories (impl)  →  DataSources  →  Models  │
│        ↓                ↓              ↓          │
│     Remote (Dio)    Local (Hive/Isar)    Drift    │
└─────────────────────────────────────────────────┘
```

---

##  Directory Structure — Complete Reference

```
bitoo/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── app.dart                           # MaterialApp.router widget
│   │
│   ├── core/                              # Shared infrastructure
│   │   ├── analytics/                     # Analytics service abstraction
│   │   │   ├── analytics_service.dart     # Interface
│   │   │   ├── mixpanel_service.dart      # Mixpanel impl
│   │   │   ├── firebase_service.dart      # Firebase Analytics impl
│   │   │   └── events.dart                # Event enum definitions
│   │   │
│   │   ├── cache/                         # Multi-tier caching
│   │   │   ├── cache_manager.dart         # Orchestrator (memory → disk)
│   │   │   ├── memory_cache.dart          # In-memory LRU cache
│   │   │   ├── disk_cache.dart            # Hive-backed disk cache
│   │   │   └── cache_policy.dart          # TTL, eviction strategies
│   │   │
│   │   ├── constants/                     # App-wide constants
│   │   │   ├── api_constants.dart         # Base URLs, endpoints
│   │   │   ├── app_constants.dart         # App-wide magic numbers
│   │   │   ├── duration_constants.dart    # Timeouts, intervals
│   │   │   └── storage_keys.dart          # Hive/SharedPrefs keys
│   │   │
│   │   ├── database/                      # Local database layer
│   │   │   ├── app_database.dart          # Drift database definition
│   │   │   ├── tables/                    # Drift table definitions
│   │   │   └── daos/                      # Data access objects
│   │   │
│   │   ├── di/                            # Dependency injection
│   │   │   ├── providers.dart             # Top-level Riverpod providers
│   │   │   ├── core_providers.dart        # Core services
│   │   │   └── feature_providers.dart     # Feature-level aggregator
│   │   │
│   │   ├── env/                           # Environment configuration
│   │   │   ├── env_config.dart            # Abstract env reader
│   │   │   ├── dev_config.dart            # Dev environment
│   │   │   ├── staging_config.dart        # Staging environment
│   │   │   └── prod_config.dart           # Production environment
│   │   │
│   │   ├── errors/                        # Error handling framework
│   │   │   ├── failures.dart              # Failure sealed class hierarchy
│   │   │   ├── exceptions.dart            # Exception classes
│   │   │   ├── error_handler.dart         # Global error handler
│   │   │   └── error_logger.dart          # Error reporting service
│   │   │
│   │   ├── extensions/                    # Dart extension methods
│   │   │   ├── context_extensions.dart    # BuildContext helpers
│   │   │   ├── string_extensions.dart     # String utilities
│   │   │   ├── datetime_extensions.dart   # DateTime helpers
│   │   │   ├── num_extensions.dart        # Number formatting
│   │   │   └── widget_extensions.dart     # Widget modifiers
│   │   │
│   │   ├── logger/                        # Structured logging
│   │   │   ├── logger_service.dart        # Logger interface
│   │   │   ├── logger_impl.dart           # Concrete logger
│   │   │   └── log_filter.dart            # Log level filtering
│   │   │
│   │   ├── network/                       # HTTP networking
│   │   │   ├── dio_client.dart            # Dio instance factory
│   │   │   ├── interceptors/             # Dio interceptors
│   │   │   │   ├── auth_interceptor.dart       # Token injection
│   │   │   │   ├── logging_interceptor.dart    # Request/response logging
│   │   │   │   ├── cache_interceptor.dart      # HTTP caching
│   │   │   │   ├── retry_interceptor.dart      # Auto-retry with backoff
│   │   │   │   ├── connectivity_interceptor.dart # Network-aware
│   │   │   │   └── header_interceptor.dart     # Standard headers
│   │   │   ├── api_result.dart           # Generic API response wrapper
│   │   │   ├── network_info.dart         # Connectivity checker
│   │   │   └── api_exceptions.dart       # HTTP-specific exceptions
│   │   │
│   │   ├── resources/                     # Resource management
│   │   │   ├── resource.dart             # Resource<T> sealed class
│   │   │   └── resource_manager.dart     # Resource loading
│   │   │
│   │   ├── router/                        # GoRouter configuration
│   │   │   ├── app_router.dart           # Router definition
│   │   │   ├── route_names.dart          # Named route constants
│   │   │   ├── route_guards.dart         # Auth guards
│   │   │   └── route_transitions.dart    # Custom transitions
│   │   │
│   │   ├── security/                      # Security layer
│   │   │   ├── secure_storage.dart       # FlutterSecureStorage wrapper
│   │   │   ├── token_manager.dart        # JWT management
│   │   │   ├── ssl_pinning.dart          # Certificate pinning
│   │   │   ├── encryption_service.dart   # AES encryption
│   │   │   ├── obfuscation.dart          # String obfuscation
│   │   │   └── jailbreak_detection.dart  # Root/jailbreak check
│   │   │
│   │   ├── services/                      # Core platform services
│   │   │   ├── connectivity_service.dart # Network state stream
│   │   │   ├── app_lifecycle.dart        # App lifecycle observer
│   │   │   ├── deeplink_service.dart     # Deep link handling
│   │   │   ├── permissions_service.dart  # Runtime permissions
│   │   │   └── app_version.dart          # Version management
│   │   │
│   │   ├── theme/                         # Material 3 theming
│   │   │   ├── app_theme.dart            # ThemeData factory
│   │   │   ├── color_schemes.dart        # Light/dark color schemes
│   │   │   ├── text_styles.dart          # Typography
│   │   │   ├── spacing.dart              # Spacing constants
│   │   │   └── theme_provider.dart       # Theme mode Riverpod provider
│   │   │
│   │   └── utils/                         # Pure utility functions
│   │       ├── validators.dart            # Form validation
│   │       ├── formatters.dart            # Display formatters
│   │       ├── debouncer.dart             # Debounce utility
│   │       ├── throttler.dart             # Throttle utility
│   │       ├── image_utils.dart           # Image helpers
│   │       └── platform_utils.dart        # Platform detection
│   │
│   ├── features/                          # Feature modules (vertical slices)
│   │   │
│   │   ├── audio_service/                 # Background audio playback
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── audio_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── audio_state_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── audio_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── audio_track.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── audio_repository.dart  # abstract
│   │   │   │   └── usecases/
│   │   │   │       ├── play_track.dart
│   │   │   │       ├── pause_track.dart
│   │   │   │       ├── seek_track.dart
│   │   │   │       ├── skip_next.dart
│   │   │   │       ├── skip_previous.dart
│   │   │   │       ├── toggle_shuffle.dart
│   │   │   │       └── set_repeat_mode.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── audio_player_provider.dart
│   │   │       │   └── audio_state_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── mini_player.dart
│   │   │       └── widgets/
│   │   │           ├── player_controls.dart
│   │   │           ├── seek_bar.dart
│   │   │           └── volume_slider.dart
│   │   │
│   │   ├── auth/                          # Authentication
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   │   └── auth_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── user_model.dart
│   │   │   │   │   └── auth_token_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── user.dart
│   │   │   │   │   └── auth_token.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart   # abstract
│   │   │   │   └── usecases/
│   │   │   │       ├── sign_in.dart
│   │   │   │       ├── sign_up.dart
│   │   │   │       ├── sign_out.dart
│   │   │   │       ├── forgot_password.dart
│   │   │   │       ├── refresh_token.dart
│   │   │   │       └── get_current_user.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── auth_provider.dart
│   │   │       │   └── auth_state_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── login_page.dart
│   │   │       │   ├── register_page.dart
│   │   │       │   └── forgot_password_page.dart
│   │   │       └── widgets/
│   │   │           ├── auth_text_field.dart
│   │   │           ├── social_login_button.dart
│   │   │           └── auth_divider.dart
│   │   │
│   │   ├── home/                          # Home feed
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── home_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── home_feed_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── home_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── feed_section.dart
│   │   │   │   │   └── banner.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── home_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       └── get_home_feed.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── home_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── home_page.dart
│   │   │       └── widgets/
│   │   │           ├── feed_section_card.dart
│   │   │           ├── banner_carousel.dart
│   │   │           └── quick_picks.dart
│   │   │
│   │   ├── search/                        # Search & discovery
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── search_remote_datasource.dart
│   │   │   │   │   └── search_local_datasource.dart  # Recent searches
│   │   │   │   ├── models/
│   │   │   │   │   ├── search_result_model.dart
│   │   │   │   │   └── recent_search_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── search_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── search_result.dart
│   │   │   │   │   └── search_category.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── search_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── search_tracks.dart
│   │   │   │       ├── search_albums.dart
│   │   │   │       ├── search_artists.dart
│   │   │   │       ├── get_search_suggestions.dart
│   │   │   │       └── save_recent_search.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── search_provider.dart
│   │   │       │   └── search_history_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── search_page.dart
│   │   │       └── widgets/
│   │   │           ├── search_bar_widget.dart
│   │   │           ├── search_result_tile.dart
│   │   │           ├── search_category_chip.dart
│   │   │           └── recent_search_tile.dart
│   │   │
│   │   ├── library/                       # User's personal library
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── library_remote_datasource.dart
│   │   │   │   │   └── library_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── library_item_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── library_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── library_item.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── library_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_library_items.dart
│   │   │   │       ├── add_to_library.dart
│   │   │   │       ├── remove_from_library.dart
│   │   │   │       └── is_in_library.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── library_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── library_page.dart
│   │   │       └── widgets/
│   │   │           ├── library_tile.dart
│   │   │           └── library_sort_filter.dart
│   │   │
│   │   ├── player/                        # Full-screen player
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── player_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── queue_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── player_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── queue.dart
│   │   │   │   │   └── playback_position.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── player_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_queue.dart
│   │   │   │       ├── add_to_queue.dart
│   │   │   │       ├── remove_from_queue.dart
│   │   │   │       ├── reorder_queue.dart
│   │   │   │       └── clear_queue.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── fullscreen_player_provider.dart
│   │   │       │   └── queue_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── fullscreen_player_page.dart
│   │   │       └── widgets/
│   │   │           ├── album_art_view.dart
│   │   │           ├── track_info.dart
│   │   │           ├── progress_bar.dart
│   │   │           ├── queue_sheet.dart
│   │   │           └── lyrics_view.dart
│   │   │
│   │   ├── playlist/                      # Playlist management
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── playlist_remote_datasource.dart
│   │   │   │   │   └── playlist_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── playlist_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── playlist_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── playlist.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── playlist_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── create_playlist.dart
│   │   │   │       ├── delete_playlist.dart
│   │   │   │       ├── update_playlist.dart
│   │   │   │       ├── get_playlist_detail.dart
│   │   │   │       ├── add_track_to_playlist.dart
│   │   │   │       ├── remove_track_from_playlist.dart
│   │   │   │       └── reorder_playlist_tracks.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── playlist_provider.dart
│   │   │       │   └── playlist_detail_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── playlist_detail_page.dart
│   │   │       │   └── create_playlist_page.dart
│   │   │       └── widgets/
│   │   │           ├── playlist_tile.dart
│   │   │           ├── track_in_playlist_tile.dart
│   │   │           └── add_to_playlist_sheet.dart
│   │   │
│   │   ├── album/                         # Album browsing
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── album_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── album_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── album_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── album.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── album_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_album_detail.dart
│   │   │   │       ├── get_album_tracks.dart
│   │   │   │       └── get_featured_albums.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── album_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── album_detail_page.dart
│   │   │       └── widgets/
│   │   │           ├── album_card.dart
│   │   │           └── album_track_list.dart
│   │   │
│   │   ├── artist/                        # Artist profile
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── artist_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── artist_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── artist_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── artist.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── artist_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_artist_detail.dart
│   │   │   │       ├── get_artist_top_tracks.dart
│   │   │   │       ├── get_artist_albums.dart
│   │   │   │       └── follow_artist.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── artist_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── artist_detail_page.dart
│   │   │       └── widgets/
│   │   │           ├── artist_header.dart
│   │   │           ├── artist_top_tracks.dart
│   │   │           └── artist_discography.dart
│   │   │
│   │   ├── explore/                       # Explore & discover
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── explore_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── explore_section_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── explore_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── explore_section.dart
│   │   │   │   │   └── genre.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── explore_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_explore_sections.dart
│   │   │   │       ├── get_genres.dart
│   │   │   │       └── get_moods_and_activities.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── explore_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── explore_page.dart
│   │   │       └── widgets/
│   │   │           ├── genre_grid.dart
│   │   │           ├── mood_card.dart
│   │   │           └── trending_section.dart
│   │   │
│   │   ├── equalizer/                     # Audio equalizer
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── equalizer_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── equalizer_preset_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── equalizer_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── equalizer_preset.dart
│   │   │   │   │   └── band_level.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── equalizer_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_presets.dart
│   │   │   │       ├── apply_preset.dart
│   │   │   │       ├── custom_band_adjust.dart
│   │   │   │       └── save_custom_preset.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── equalizer_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── equalizer_page.dart
│   │   │       └── widgets/
│   │   │           ├── band_slider.dart
│   │   │           ├── preset_chip.dart
│   │   │           └── frequency_graph.dart
│   │   │
│   │   ├── settings/                      # User settings
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── settings_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── settings_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── settings_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── app_settings.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── settings_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_settings.dart
│   │   │   │       ├── update_settings.dart
│   │   │   │       ├── reset_settings.dart
│   │   │   │       └── toggle_dark_mode.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── settings_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── settings_page.dart
│   │   │       │   ├── audio_settings_page.dart
│   │   │       │   ├── storage_settings_page.dart
│   │   │       │   └── privacy_settings_page.dart
│   │   │       └── widgets/
│   │   │           ├── settings_section.dart
│   │   │           ├── settings_tile.dart
│   │   │           └── settings_dialog.dart
│   │   │
│   │   ├── downloads/                     # Offline downloads
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── download_remote_datasource.dart
│   │   │   │   │   └── download_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── download_task_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── download_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── download_task.dart
│   │   │   │   │   └── download_status.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── download_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── download_track.dart
│   │   │   │       ├── pause_download.dart
│   │   │   │       ├── resume_download.dart
│   │   │   │       ├── cancel_download.dart
│   │   │   │       ├── get_downloads.dart
│   │   │   │       └── delete_download.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── download_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── downloads_page.dart
│   │   │       └── widgets/
│   │   │           ├── download_tile.dart
│   │   │           ├── download_progress.dart
│   │   │           └── download_controls.dart
│   │   │
│   │   ├── notifications/                 # Push notifications
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── notification_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── notification_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── notification_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── app_notification.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── notification_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── register_for_push.dart
│   │   │   │       ├── handle_notification_tap.dart
│   │   │   │       └── get_notification_history.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── notification_provider.dart
│   │   │       └── widgets/
│   │   │           └── notification_badge.dart
│   │   │
│   │   ├── social/                        # Social features
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── social_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── social_post_model.dart
│   │   │   │   │   └── friend_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── social_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── social_post.dart
│   │   │   │   │   ├── friend.dart
│   │   │   │   │   └── activity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── social_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_friends_activity.dart
│   │   │   │       ├── share_playlist.dart
│   │   │   │       └── follow_friend.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── social_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── social_page.dart
│   │   │       └── widgets/
│   │   │           ├── activity_feed_tile.dart
│   │   │           └── friend_card.dart
│   │   │
│   │   ├── onboarding/                    # First-run experience
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── onboarding_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── onboarding_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── onboarding_step.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── onboarding_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── is_onboarding_complete.dart
│   │   │   │       └── complete_onboarding.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── onboarding_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── onboarding_page.dart
│   │   │       └── widgets/
│   │   │           ├── onboarding_step_widget.dart
│   │   │           └── onboarding_dots.dart
│   │   │
│   │   └── splash/                        # Splash / init
│   │       ├── data/
│   │       │   ├── datasources/
│   │       │   │   └── splash_datasource.dart
│   │       │   └── repositories/
│   │       │       └── splash_repository_impl.dart
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   └── app_init_status.dart
│   │       │   ├── repositories/
│   │       │   │   └── splash_repository.dart
│   │       │   └── usecases/
│   │       │       └── initialize_app.dart
│   │       └── presentation/
│   │           ├── providers/
│   │           │   └── splash_provider.dart
│   │           ├── pages/
│   │           │   └── splash_page.dart
│   │           └── widgets/
│   │               └── splash_animation.dart
│   │
│   ├── shared/                            # Shared cross-feature code
│   │   ├── models/                        # Shared DTOs
│   │   │   ├── track_summary.dart
│   │   │   ├── page_meta.dart
│   │   │   └── paginated_response.dart
│   │   ├── providers/                     # Shared providers
│   │   │   ├── connectivity_provider.dart
│   │   │   └── platform_provider.dart
│   │   ├── widgets/                       # Shared widgets
│   │   │   ├── app_scaffold.dart
│   │   │   ├── app_bar_widget.dart
│   │   │   ├── bottom_nav_bar.dart
│   │   │   ├── loading_indicator.dart
│   │   │   ├── error_widget.dart
│   │   │   ├── empty_state_widget.dart
│   │   │   ├── retry_widget.dart
│   │   │   ├── responsive_grid.dart
│   │   │   ├── responsive_builder.dart
│   │   │   ├── shimmer_loading.dart
│   │   │   ├── cached_network_image.dart
│   │   │   ├── platform_adaptive_widget.dart
│   │   │   ├── slide_transition.dart
│   │   │   └── confirmation_dialog.dart
│   │   └── extensions/                    # Shared extensions
│   │       └── context_extensions.dart
│   │
│   ├── l10n/                              # Localization
│   │   ├── app_en.arb
│   │   ├── app_es.arb
│   │   ├── app_fr.arb
│   │   └── ...
│   │
│   └── gen/                               # Code-generated files
│       └── ...
│
├── test/
│   ├── unit/                              # Unit tests
│   │   └── features/
│   │       ├── auth/
│   │       ├── home/
│   │       └── ...
│   ├── widget/                            # Widget tests
│   │   └── features/
│   ├── integration/                       # Integration tests
│   ├── fixtures/                          # Test JSON fixtures
│   │   ├── auth/
│   │   ├── home/
│   │   └── ...
│   └── mocks/                             # Mock classes
│       ├── mock_audio_service.mocks.dart
│       ├── mock_auth_repository.mocks.dart
│       └── ...
│
├── assets/
│   ├── images/
│   │   ├── logo.png
│   │   ├── logo_dark.png
│   │   ├── placeholder_album.png
│   │   └── ...
│   ├── icons/
│   │   └── custom_icons/
│   ├── fonts/
│   │   ├── Inter-Regular.ttf
│   │   ├── Inter-Bold.ttf
│   │   └── ...
│   ├── audio/
│   │   └── silence.mp3                    # For audio focus
│   └── i18n/
│       └── ...
│
├── scripts/                               # Build & CI scripts
│   ├── build_runner.sh
│   ├── code_analysis.sh
│   ├── test_coverage.sh
│   ├── generate_icons.sh
│   ├── generate_splash.sh
│   ├── clean.sh
│   └── ...
│
├── tools/                                 # Internal dev tools
│   └── dart_code_gen/                     # Custom code generator
│
├── docs/                                  # Architecture docs
│   ├── ARCHITECTURE.md
│   ├── CODING_STANDARDS.md
│   ├── GIT_STRATEGY.md
│   ├── RELEASE_CHECKLIST.md
│   └── ...
│
├── coverage/                              # Test coverage reports
├── .dart_tool/
├── .idea/
├── .vscode/
│   ├── settings.json
│   ├── launch.json
│   └── extensions.json
│
├── android/
│   ├── app/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── jniLibs/              # Native audio libs
│   │   │       ├── proguard-rules.pro
│   │   │       └── AndroidManifest.xml
│   │   ├── build.gradle
│   │   └── ...
│   └── ...
│
├── ios/
│   └── ...
│
├── pubspec.yaml
├── analysis_options.yaml
├── l10n.yaml
├── build.yaml
├── .gitignore
├── .env.dev
├── .env.staging
├── .env.prod
└── README.md
```

---

##  Layer Definitions

### 1. CORE Layer — `lib/core/`

**Purpose:** Application infrastructure — zero business logic. Contains all
cross-cutting concerns that every feature depends on.

| Sub-package | Responsibility | Key Technologies |
|-------------|---------------|-----------------|
| `analytics/` | Event tracking abstraction | Mixpanel, Firebase Analytics |
| `cache/` | Multi-tier (memory → disk) | LRU Map, Hive |
| `constants/` | Immutable configuration | Raw Dart constants |
| `database/` | Local relational DB | Drift (SQLite) |
| `di/` | Dependency graph wiring | Riverpod providers |
| `env/` | Environment-specific config | `.env` files, `--dart-define` |
| `errors/` | Failure & exception hierarchy | Sealed classes, `Result` type |
| `extensions/` | Dart extension methods | Pure Dart |
| `logger/` | Structured logging | `logging` package |
| `network/` | HTTP client & interceptors | Dio |
| `resources/` | Resource state management | `AsyncValue` wrapper |
| `router/` | Navigation graph | GoRouter |
| `security/` | Encryption, tokens, pinning | `flutter_secure_storage`, `crypto` |
| `services/` | Platform-level services | `connectivity_plus`, `permission_handler` |
| `theme/` | M3 design system | Material 3 `ColorScheme` |
| `utils/` | Pure utility functions | Stateless helpers |

### 2. FEATURES Layer — `lib/features/`

**Purpose:** Vertical business capability slices. Each feature is independently
understandable, testable, and (optionally) shippable.

Every feature follows this exact internal structure:

```
feature_name/
├── data/               # Implementation layer
│   ├── datasources/    # Remote (API) + Local (DB/Preferences)
│   ├── models/         # JSON-serializable DTOs (fromJson/toJson)
│   └── repositories/   # Concrete implementations of domain interfaces
├── domain/             # Business logic layer (pure Dart, zero deps)
│   ├── entities/       # Business objects
│   ├── repositories/   # Abstract interfaces (contracts)
│   └── usecases/       # Single-responsibility operations
└── presentation/       # UI layer
    ├── providers/      # Riverpod StateNotifier/AsyncNotifier providers
    ├── pages/          # Full-screen views (routes)
    └── widgets/        # Reusable UI components for this feature
```

#### Data Flow per Feature:

```
UI (Widget)
  → reads Provider (Riverpod)
    → calls UseCase (domain)
      → calls Repository interface (domain)
        → RepositoryImpl (data) delegates to:
            → RemoteDataSource (Dio) AND/OR
            → LocalDataSource (Hive/Isar/Drift)
              → returns Model (data)
                → mapped to Entity (domain)
                  → wrapped in Resource<Entity> (core)
                    → Provider exposes AsyncValue<Entity> (Riverpod)
                      → UI rebuilds
```

### 3. SHARED Layer — `lib/shared/`

**Purpose:** Reusable components used by multiple features. NOT a dumping
ground — if a widget is used by exactly one feature, it lives in that feature.

| Sub-package | Contents |
|-------------|----------|
| `widgets/` | App-scaffold, bottom nav, loading/error/empty states, responsive grid, shimmer, dialogs |
| `models/` | Shared domain DTOs (pagination, track summary) |
| `providers/` | Cross-cutting providers (connectivity, platform) |
| `extensions/` | BuildContext convenience extensions |

---

##  Package Strategy (pubspec.yaml Dependencies)

```yaml
# ─── STATE MANAGEMENT ───
  flutter_riverpod: ^2.5.0       # State management
  riverpod_annotation: ^2.3.0    # Code generation for providers

# ─── NAVIGATION ───
  go_router: ^14.0.0             # Declarative routing

# ─── NETWORKING ───
  dio: ^5.4.0                    # HTTP client
  retrofit: ^4.1.0               # Type-safe API client generation
  connectivity_plus: ^6.0.0      # Network state detection

# ─── LOCAL STORAGE ───
  hive: ^2.2.3                   # Fast key-value + object store
  hive_flutter: ^1.1.0           # Flutter-specific Hive
  isar: ^3.1.0                   # High-performance NoSQL (offline-first)
  isar_flutter_libs: ^3.1.0     # Isar native libs
  drift: ^2.16.0                 # SQLite ORM (for relational data)
  sqlite3_flutter_libs: ^0.5.0  # SQLite native libs
  shared_preferences: ^2.2.0    # Simple key-value (settings only)
  flutter_secure_storage: ^9.0.0 # Encrypted storage

# ─── AUDIO ───
  just_audio: ^0.9.36            # Audio playback
  audio_service: ^0.18.0         # Background audio + notification
  just_audio_background: ^0.0.1  # Background integration

# ─── FIREBASE ───
  firebase_core: ^2.27.0
  firebase_analytics: ^10.10.0
  firebase_crashlytics: ^3.5.0
  firebase_remote_config: ^4.4.0
  firebase_messaging: ^14.9.0

# ─── UI ───
  cached_network_image: ^3.3.0   # Image caching
  shimmer: ^3.0.0                # Loading skeletons
  flutter_svg: ^2.0.0            # SVG icons
  equatable: ^2.0.5              # Value equality
  freezed_annotation: ^2.4.0     # Immutable data classes
  json_annotation: ^4.8.0        # JSON serialization

# ─── UTILITIES ───
  intl: ^0.19.0                  # i18n
  path_provider: ^2.1.0          # File system paths
  permission_handler: ^11.3.0    # Runtime permissions
  url_launcher: ^6.2.0           # External URLs
  package_info_plus: ^8.0.0      # App version info
  device_info_plus: ^10.0.0      # Device info
  flutter_local_notifications: ^17.0.0

# ─── SECURITY ───
  crypto: ^3.0.3                 # Hashing
  encrypt: ^5.0.3                # AES encryption
  pointycastle: ^3.8.0           # Cryptographic algorithms

# ─── EQUALIZER ───
  audio_session: ^0.1.21         # Audio session management

# ─── DEVELOPMENT ONLY ───
dev_dependencies:
  flutter_test:
  mocktail: ^1.0.0               # Mocking
  mockito: ^5.4.0                # Alternative mocking
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.4.0
  retrofit_generator: ^8.1.0
  drift_dev: ^2.16.0
  isar_generator: ^3.1.0
  hive_generator: ^2.0.0
  flutter_lints: ^4.0.0
  custom_lint: ^0.6.0
  dart_code_metrics: ^5.0.0      # Advanced linting
  test: ^1.25.0
  golden_toolkit: ^0.15.0        # Golden tests
  integration_test:
    sdk: flutter
```

---

##  Route Architecture (GoRouter)

```dart
// Route tree:
// /
// ├── /onboarding
// ├── /auth
// │   ├── /auth/login
// │   ├── /auth/register
// │   └── /auth/forgot-password
// └── /home (ShellRoute with BottomNavigationBar)
//     ├── /home/feed            (tab 0)
//     ├── /home/explore         (tab 1)
//     ├── /home/library         (tab 2)
//     └── /home/search          (tab 3)
// ├── /player                   (full-screen / overlay)
// ├── /album/:id
// ├── /artist/:id
// ├── /playlist/:id
// ├── /playlist/:id/create
// ├── /settings
// │   ├── /settings/audio
// │   ├── /settings/storage
// │   ├── /settings/privacy
// │   └── /settings/about
// ├── /downloads
// ├── /equalizer
// ├── /social
// └── /notification-history
```

Router configuration in `lib/core/router/app_router.dart` with:
- **ShellRoute** for persistent bottom nav + mini-player
- **AuthGuard** redirect for protected routes
- **Deep link** support
- **Custom transitions** per route group
- **404** fallback page
- **Nested routes** with parent-child state preservation

---

##  Provider Architecture (Riverpod)

```
                    ┌──────────────────────┐
                    │   appRouterProvider   │
                    │  (GoRouter instance)   │
                    └──────────┬───────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                 │
    ┌─────────▼──────┐  ┌─────▼──────┐  ┌──────▼───────┐
    │ authStateProvider│  │ themeProvider│  │ connectivity │
    │ (AsyncNotifier) │  │(StateNotif.)│  │  Provider    │
    └─────────┬───────┘  └────────────┘  └──────────────┘
              │
    ┌─────────▼──────────────────────────────────────────┐
    │              Feature-Scoped Providers                │
    │                                                     │
    │  ┌──────────┐  ┌───────────┐  ┌────────────────┐   │
    │  │  home    │  │  search   │  │    player      │   │
    │  │ Provider │  │  Provider │  │   Provider     │   │
    │  └──────────┘  └───────────┘  └────────────────┘   │
    │                                                     │
    └─────────────────────────────────────────────────────┘
```

- **Provider type hierarchy:**
  - `Provider` — synchronous dependency injection
  - `FutureProvider` — async one-shot reads
  - `StreamProvider` — real-time streams
  - `StateNotifierProvider` — mutable state with logic
  - `AsyncNotifierProvider` — async state with logic
  - `NotifierProvider` — synchronous mutable state (v2)
  - `Family` variants — parameterized providers

- **Scoping:** Providers are scoped at feature level. Feature providers
  compose core providers via `ref.watch`.

---

##  Result / Error Pattern

```dart
// Core sealed class for all operation results
sealed class Resource<T> {
  const Resource();
}

class Success<T> extends Resource<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Resource<T> {
  final FailureReason error;
  const Failure(this.error);
}

class Loading<T> extends Resource<T> {
  const Loading();
}

// Failure hierarchy (sealed)
sealed class FailureReason {
  const FailureReason();
}

// Network failures
class NetworkFailure extends FailureReason {
  final String? message;
  final int? statusCode;
  const NetworkFailure({this.message, this.statusCode});
}

// Auth failures
class UnauthorizedFailure extends FailureReason {
  const UnauthorizedFailure();
}

// Cache failures
class CacheFailure extends FailureReason {
  final String message;
  const CacheFailure(this.message);
}

// Business logic failures
class ValidationFailure extends FailureReason {
  final String message;
  final Map<String, String>? fieldErrors;
  const ValidationFailure(this.message, {this.fieldErrors});
}
```

---

##  Scalability Principles

1. **Feature isolation** — Deleting a feature folder has zero impact on others.
2. **Dependency inversion** — `domain/` depends on NOTHING. Pure Dart.
3. **Lazy loading** — Features are loaded on-demand via Riverpod `family`.
4. **Repository caching strategy** — Network-first, cache-fallback, offline-mode.
5. **Code generation** — Freezed for data classes, Retrofit for APIs, Riverpod
   generator for providers. Zero boilerplate.
6. **Modular testing** — Each layer is independently mockable.
7. **Responsive by default** — Every page uses `LayoutBuilder` / `Breakpoints`
   to adapt to phone, tablet, foldable, and desktop widths.
