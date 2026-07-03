# Animation System

## Design Philosophy

Every interaction must feel tactile, responsive, and buttery-smooth at 120 FPS.
Animations communicate state, guide attention, and create a premium haptic-like experience without physical haptics.

## Animation Principles

1. **Duration**: Micro-interactions ≤200ms, transitions ≤350ms, hero animations ≤500ms
2. **Curves**: Custom cubic beziers — never linear, never default
3. **Physics**: Spring-based for natural feel, easeInOutCubic for transitions
4. **Stagger**: List items stagger at 40ms intervals, max 300ms total
5. **Parallax**: Depth layering at 0.8x/0.9x/1.0x scroll speeds
6. **Glassmorphism**: Animated backdrop blur, opacity transitions for glass cards

## Curve Definitions

| Name | Cubic Bezier | Use Case |
|------|-------------|----------|
| `premiumEase` | (0.16, 1, 0.3, 1) | Default — buttons, cards, micro-interactions |
| `premiumEaseOut` | (0.0, 0.0, 0.2, 1) | Page transitions, hero animations |
| `premiumEaseIn` | (0.4, 0.0, 1, 1) | Exit animations, dismissals |
| `spring` | Spring(damping: 0.7, stiffness: 300) | Natural physics-based motion |
| `springBouncy` | Spring(damping: 0.5, stiffness: 200) | Fun elements, like/dislike |
| `emphasized` | (0.2, 0.0, 0.0, 1.0) | Large screen transitions (iOS-style) |

## Duration Scale

| Token | ms | Usage |
|-------|----|-------|
| `micro` | 100 | Button down state, ripple |
| `fast` | 180 | Hover, tap feedback, toggle switch |
| `normal` | 300 | Card expand, list item appear |
| `slow` | 450 | Page transition, hero animation |
| `slower` | 700 | Modal presentation, complex layout |
| `slowest` | 1000 | Splash, intro sequences |

## Animation Types

### 1. Micro Animations

| Widget | Trigger | Animation | Duration | Curve |
|--------|---------|-----------|----------|-------|
| AnimatedIconButton | Tap | Scale 0.95→1.0 + color elevation | 100ms | premiumEase |
| ScaleOnTap | Press | Scale 0.96→1.0 | 150ms | spring |
| PulseEffect | Auto | Scale 1.0→1.05→1.0 (infinite) | 1200ms | easeInOut |
| GlassHover | Pointer enter/exit | Opacity 0.1→0.2 backdrop | 180ms | premiumEase |
| RippleReveal | Tap | Radial reveal from touch point | 300ms | premiumEaseOut |

### 2. Hero & Shared Transitions

| Transition | From | To | Duration | Curve |
|------------|------|----|----------|-------|
| AlbumArtHero | Card grid | Fullscreen player | 450ms | premiumEaseOut |
| PlaylistCoverHero | List row | Playlist detail | 400ms | premiumEaseOut |
| AvatarHero | Settings row | Profile view | 350ms | premiumEaseOut |
| SearchBarHero | Mini bar | Full search page | 300ms | spring |

### 3. Page Transitions (GoRouter)

| Transition | Direction | Duration | Curve | Swap |
|------------|-----------|----------|-------|------|
| SlideUp | Bottom → Top | 350ms | premiumEaseOut | Push |
| SlideDown | Top → Bottom | 300ms | premiumEaseIn | Pop |
| ZoomIn | Scale 0.92 + fade | 400ms | premiumEaseOut | Modal |
| SharedAxisZ | Z-axis depth | 350ms | emphasized | Push |
| FadeThrough | Cross-fade | 300ms | easeInOut | Tab swap |

### 4. Animated Cards

| Card Type | Idle | Hover | Press | Active |
|-----------|------|-------|-------|--------|
| AlbumCard | Flat | Lift 4dp + glow | Scale 0.97 | Border glow |
| PlaylistCard | Flat | Lift 3dp + shadow | Scale 0.96 | Accent border |
| TrackTile | Flat | Background tint | Scale 0.98 | Playing indicator |
| SectionHeader | Flat | No hover | No press | Expand indicator |

3D Tilt Effect (Touch cards):
- Gyroscope x/y rotation: ±5 degrees
- Shadow displacement proportional to tilt
- Gloss highlight moves with tilt
- Only on devices with sensors; fallback: static parallax

### 5. Animated Player

| Element | Animation | Trigger |
|---------|-----------|---------|
| NowPlayingBar | Slide up from bottom | Track starts |
| FullscreenPlayer | Expand from bar position | Tap bar |
| Vinyl Rotation | 0→360° continuous, 4s per rotation | Playing |
| Vinyl Speed Change | 4s→8s interp on pause | Pause |
| AlbumArt Parallax | Slow drift 3px on gyro | Active |
| Waveform Visualization | Frequency bars animate to beat | Playing |
| Seek Thumb | Trailing glow pulse | Dragging |
| Track Progress | Gradient fill behind thumb | Playing |
| Like Animation | Scale 0→1.2→1.0 bounce | Tap heart |
| Shuffle/Repeat toggle | Rotation 360° + scale | Toggle |

### 6. Animated Search

| Element | Animation | Duration | Curve |
|---------|-----------|----------|-------|
| SearchBar Expand | Width 48→full | 300ms | spring |
| SearchBar Collapse | Width full→48 | 250ms | premiumEase |
| Search Icon | Magnify→Arrow morph | 200ms | premiumEase |
| Recent Searches | Fade in staggered (40ms) | 300ms total | easeOut |
| Search Results | Slide up + fade, staggered | 400ms total | premiumEase |
| Clear Button | Scale 0→1 pop | 180ms | springBouncy |
| Filter Chips | Horizontal slide-in | 250ms | premiumEase |

### 7. Animated Settings

| Element | Animation | Duration | Curve |
|---------|-----------|----------|-------|
| Section Header | Sticky parallax on scroll | — | — |
| Tile Entry | Slide from right 10px + fade | 300ms | premiumEase |
| Toggle Switch | iOS-style spring (damping:0.6) | 200ms | spring |
| Slider | Thumb scale 1.0→1.3 on drag | 100ms | premiumEase |
| List Reorder | Spring to new position | 300ms | spring |
| Chevron | 0→90° rotation on expand | 200ms | premiumEase |

### 8. Animated Playlists

| Element | Animation | Duration | Curve |
|---------|-----------|----------|-------|
| Add Track | Scale 0→1 with slide | 250ms | springBouncy |
| Remove Track | Scale 1→0 + fade out | 200ms | premiumEaseIn |
| Reorder Drag | Lift +8dp + shadow | 100ms | premiumEase |
| Reorder Drop | Spring to position | 300ms | spring |
| Playlist Create | Card expands from FAB | 400ms | premiumEaseOut |
| Empty State | Illustration fade-in + bounce | 600ms | springBouncy |
| Track Count Badge | Scale pop on change | 200ms | springBouncy |

### 9. Animated Lyrics

| Element | Animation | Duration | Curve |
|---------|-----------|----------|-------|
| Line Scroll | Auto-scroll to current line | 300ms | premiumEaseOut |
| Line Highlight | Opacity 0.4→1.0 + scale 0.98→1.0 | 200ms | premiumEase |
| Line Transition | Current line slides up | 200ms | easeOut |
| Synced Word | Gradient fill per syllable | Per word | — |
| Karaoke Cursor | Moving indicator line | Continuous | linear |
| Empty Lyrics | Fade in "No lyrics" state | 300ms | easeIn |

### 10. Animated Loading

| Element | Animation | Duration | Curve |
|---------|-----------|----------|-------|
| Shimmer | Gradient sweep L→R 30px→100% | 1500ms | linear |
| Skeleton | Pulse opacity 0.3→0.6→0.3 | 1200ms | easeInOut |
| Progress Bar | Gradient sweep + indeterminate | 2000ms | linear |
| Spinner | Rotation 0→360° continuous | 800ms | linear |
| Skeleton Cards | Staggered appear + shimmer | 1200ms total | easeOut |
| Pulse Ring | Expanding ring from center | 1000ms | easeOut |

## Impeller Optimization

### Android Configuration
```xml
<!-- AndroidManifest.xml -->
<meta-data
    android:name="io.flutter.embedding.android.EnableImpeller"
    android:value="true" />
```

### Flutter Configuration
```dart
// main.dart
void main() {
  // Enable Impeller for 120 FPS rendering
  if (Platform.isAndroid) {
    // Impeller is auto-enabled in Flutter 3.27+
    // Fallback: ensure hardware rendering
  }
  runApp(const BitooApp());
}
```

### Best Practices for 120 FPS

1. **RepaintBoundary**: Wrap every scroll item, every card, every animated widget
2. **Avoid setState in deep trees**: Use granular StatefulWidget + ValueNotifier/AnimationController
3. **Use const constructors**: Every widget that can be const, should be const
4. **Image caching**: `cached_network_image` + precache for album art
5. **Layer tree minimization**: Avoid Opacity widget (use `FadeTransition` with `AnimatedOpacity`)
6. **Offstage widgets**: Use `Offstage` + `Visibility` (not `if` conditionals) for preserved state
7. **AnimatedList/GridView**: Use `SliverAnimatedList` for insert/remove animations
8. **ShaderMask sparingly**: Use `Canvas` + `CustomPainter` for complex effects

## File Architecture

```
lib/core/animations/
  curves.dart                    # Custom cubic bezier curves + springs
  durations.dart                 # Duration constants (micro→slowest)
  animation_constants.dart       # All animation configs in one place

lib/shared/animations/
  micro_animations.dart          # AnimatedIconButton, ScaleOnTap, PulseEffect, GlassHover
  shimmer_loading.dart           # Shimmer + Skeleton for all card types
  animated_card.dart             # 3D tilt card, AlbumCard, PlaylistCard with press/lift
  animated_list_item.dart        # StaggeredList, slide-in items, reorder
  page_transition_builder.dart   # GoRouter custom transitions
  animated_search_bar.dart       # Expandable search, morph icon, filter chips
  animated_toggle.dart           # Premium iOS-style toggle, chevron rotate
  animated_lyrics.dart           # Synced lyrics view with line highlight
  player_transition.dart         # Now playing bar ↔ fullscreen player
```

## Route Transition Mapping (GoRouter)

```dart
GoRouter(
  routes: [
    GoRoute(
      path: '/player',
      pageBuilder: (context, state) => PremiumSlideUpTransition(
        child: FullscreenPlayerPage(),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: '/album/:id',
      pageBuilder: (context, state) => PremiumSharedAxisTransition(
        child: AlbumDetailPage(albumId: state.pathParameters['id']!),
        key: state.pageKey,
      ),
    ),
  ],
)
```

## Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| Frame rate | 120 FPS | `flutter build --profile --enable-impeller` |
| Frame build time | <3ms | DevTools Timeline |
| Frame raster time | <5ms | DevTools Timeline |
| Shader compilation jank | 0 frames | Warm-up SkSL |
| Gesture response | <50ms | `PerformanceOverlay` |
| Page transition | <400ms | Stopwatch |
| List scroll jank | 0 frames | DevTools |
