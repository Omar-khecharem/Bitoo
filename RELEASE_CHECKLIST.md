# BITOO Release Checklist

Production deployment checklist for Google Play Store.

---

##  Pre-Release Phase (Sprint N-1)

### Feature Completion
- [ ] All planned features implemented
- [ ] Feature flags verified (enabled/disabled correctly)
- [ ] No P0 or P1 bugs open
- [ ] All P2 bugs have target fix version

### Technical Debt
- [ ] No `// TODO` without ticket reference
- [ ] No `// ignore` without explicit justification
- [ ] `dart fix --dry-run` produces 0 errors
- [ ] `dart_code_metrics` passes at 100%
- [ ] Deprecated API usage reviewed and resolved

---

##  Code Freeze Phase (Sprint N)

### Static Analysis
- [ ] `flutter analyze` — 0 errors, 0 warnings
- [ ] `dart run custom_lint` — 0 violations
- [ ] `dart format --set-exit-if-changed .` — passes
- [ ] `dart_code_metrics` — no anti-pattern violations

### Testing
- [ ] All unit tests pass: `flutter test --exclude-tags=golden`
- [ ] All widget tests pass
- [ ] All integration tests pass on physical device
- [ ] Coverage ≥ 85% (unit + widget)
- [ ] Golden tests pass on reference device
- [ ] Accessibility scan complete (no violations)
- [ ] Memory leak check (DevTools memory tab)
- [ ] Performance profile check (no jank > 16ms frames)

### Security
- [ ] SSL pinning verified against production API
- [ ] Obfuscation enabled in `build.gradle`
- [ ] ProGuard rules verified (no false positives)
- [ ] FlutterSecureStorage integration verified
- [ ] No API keys or secrets in source code
- [ ] All secrets loaded from environment variables
- [ ] JWT token refresh flow tested
- [ ] Session timeout behavior verified
- [ ] Jailbreak/root detection tested (if enabled)
- [ ] Encryption of cached offline content verified

### Database & Data
- [ ] Drift migrations tested (forward + rollback)
- [ ] Hive box schema compatibility verified
- [ ] Isar schema migrations working
- [ ] Offline mode: full CRUD without network
- [ ] Offline → Online sync strategy verified
- [ ] Cache eviction working correctly (memory + disk)
- [ ] No data loss on app upgrade
- [ ] No data loss on force stop + restart

### Audio & Playback
- [ ] Background playback works (screen off, app minimized)
- [ ] Audio focus handling tested (calls, other apps)
- [ ] Lock screen controls functional
- [ ] Notification controls functional
- [ ] Bluetooth AVRCP controls functional
- [ ] Wired headset controls functional
- [ ] Audio routing (speaker, headphones, Bluetooth) tested
- [ ] Equalizer presets apply correctly
- [ ] Gapless playback verified
- [ ] Crossfade verified
- [ ] Seek accuracy verified
- [ ] Queue persistence across restarts

### Performance
- [ ] App cold start < 2 seconds (baseline device)
- [ ] App warm start < 1 second
- [ ] Scroll performance: 60fps on target devices
- [ ] Image loading: lazy + cached + placeholders
- [ ] Memory usage < 200MB during normal operation
- [ ] Memory usage < 300MB during heavy operation
- [ ] No ANRs in 30-minute stress test
- [ ] Shimmer loading shown for all async operations
- [ ] Pagination working correctly (infinite scroll)
- [ ] Debounced search (300ms delay)
- [ ] Throttled API calls (no duplicate requests)

### UI/UX
- [ ] Material 3 dynamic color works
- [ ] Dark mode toggle verified
- [ ] Responsive layout verified: phone (360dp), tablet (600dp+), foldable
- [ ] Bottom nav + mini-player interaction smooth
- [ ] Landscape orientation tested
- [ ] Edge-to-edge display (system bar handling)
- [ ] Font scaling tested (accessibility)
- [ ] RTL layout verified (if enabled)
- [ ] No text overflow in any locale
- [ ] Touch targets ≥ 48dp
- [ ] Keyboard navigation tested
- [ ] TalkBack/Content description verified
- [ ] Semantic labels for all tappable elements

### Device Compatibility
- [ ] Android 10 (API 29) — minimum target
- [ ] Android 14 (API 34) — latest target
- [ ] Medium-end device test (4GB RAM, 720p)
- [ ] Low-end device test (2GB RAM, 540p)
- [ ] Tablet test (10-inch)
- [ ] Foldable test (Samsung Galaxy Z Fold)
- [ ] Chromebook/desktop test
- [ ] Different screen densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)

### Networking
- [ ] API response caching works (HTTP cache headers)
- [ ] Retry with exponential backoff verified
- [ ] Offline queue: requests queued when offline
- [ ] Offline queue: flush on reconnect
- [ ] Network change handling smooth (WiFi → cellular)
- [ ] No memory leaks from Dio instances
- [ ] Certificate pinning working in production
- [ ] Connection timeout handling graceful
- [ ] Response timeout handling graceful
- [ ] Token refresh race condition tested

---

##  Release Phase

### Build
- [ ] Version bumped: `pubspec.yaml` → `version: x.y.z+1`
- [ ] Build number incremented
- [ ] `flutter build appbundle --release` succeeds
- [ ] ProGuard mapping file saved
- [ ] App Bundle signed with upload key
- [ ] App Bundle size verified (< 150MB)
- [ ] Native architectures: arm64-v8a, armeabi-v7a, x86_64
- [ ] `flutter build ios --release` succeeds (if iOS enabled)

### Environment Configuration
- [ ] All URLs point to production
- [ ] Firebase project set to production
- [ ] Sentry/Crashlytics DSN set to production
- [ ] Mixpanel/Analytics project set to production
- [ ] Feature flags verified in production config
- [ ] `--dart-define` values verified (no dev defaults)

### Internal Testing (Google Play Console)
- [ ] Internal test track uploaded
- [ ] Internal testers: 5+ installs attempted
- [ ] Crashlytics reports 0 crashes in 24h
- [ ] Analytics events firing correctly
- [ ] No unusual error logs
- [ ] Battery drain test: < 5% per hour background audio
- [ ] Data usage test: < 1MB per minute streaming 320kbps

### Closed Alpha
- [ ] Closed alpha track promoted from internal
- [ ] Alpha testers: 50+ installs attempted
- [ ] Crash-free rate ≥ 99.5%
- [ ] ANR rate = 0%
- [ ] Average session length reviewed
- [ ] User feedback reviewed
- [ ] All crash reports triaged and resolved

### Open Beta
- [ ] Open beta track promoted from alpha
- [ ] Beta testers: 1000+ installs
- [ ] Crash-free rate ≥ 99.8%
- [ ] 5-star crash-free sessions rate ≥ 99.9%
- [ ] ANR rate < 0.1%
- [ ] All critical bugs from beta triaged
- [ ] Play Store listing reviewed:
  - Screenshots (phone + tablet + foldable)
  - Feature graphic
  - Description
  - Category selection
  - Content rating
  - Privacy policy link
  - Terms of service link

### Production Release
- [ ] Beta period minimum: 7 days
- [ ] All beta blockers resolved
- [ ] Production release approved by product
- [ ] Production release approved by engineering lead
- [ ] Staged rollout: 1% → 5% → 25% → 50% → 100%
- [ ] Monitoring dashboard configured (Datadog/Sentry)
- [ ] On-call engineer notified
- [ ] Rollback plan documented
- [ ] Post-release monitoring schedule defined
  - T+0h: Crash-free rate, ANR rate
  - T+1h: All metrics green
  - T+6h: Review all crash reports
  - T+24h: Review analytics funnel
  - T+72h: Review user ratings & reviews

---

##  Post-Release Phase

- [ ] Hotfix branch prepared if needed
- [ ] Next sprint features unblocked
- [ ] Release tagged in git: `git tag -a v1.2.3 -m "v1.2.3"`
- [ ] Release notes published
- [ ] Performance benchmarks compared to previous release
- [ ] Regression test suite updated with any new flows
