# BITOO Home Screen — Extraordinary Design

> The first thing users see. It must feel alive, personal, and infinitely
> scrollable — like a curated gallery of their music world.

---

##  Design Philosophy

| Principle | Application |
|-----------|-------------|
| **Personal** | Content adapts to listening habits. "Continue Listening" is first. |
| **Alive** | Hero background animates with subtle color shifts. Cards pulse on hover. |
| **Efficient** | One thumb reach to every section. Horizontal scrolls conserve vertical space. |
| **Discoverable** | Moods and genres invite exploration. Quick actions reduce friction. |
| **Responsive** | Phone: 2-column grid. Tablet: 3-column + sidebar. Desktop: full layout. |

---

##  Screen Layout (Z-Index Order)

```
┌──────────────────────────────────────────────────────────┐
│  Layer 6: Mini Player (64dp, glass, fixed bottom)         │
│  Layer 5: Bottom Navigation (72dp, glass, fixed)          │
│  Layer 4: Sticky Quick Actions (when hero scrolled off)   │
│  Layer 3: Scrollable Content                              │
│  Layer 2: Section Wrappers (background surfaces)          │
│  Layer 1: Hero Header (animated gradient, dynamic color)  │
│  Layer 0: Background (#0A0A0F)                            │
└──────────────────────────────────────────────────────────┘
```

##  Component Tree

```
HomePage
├── Scaffold
│   ├── body: CustomScrollView
│   │   ├── SliverAppBar (collapses hero)
│   │   │   └── HeroHeader
│   │   │       ├── AnimatedBackground (gradient shift, 8s loop)
│   │   │       ├── GreetingText ("Good evening")
│   │   │       ├── UserAvatar (top-right, 36dp)
│   │   │       ├── SearchBar (glass, compact, tappable → full search)
│   │   │       └── QuickActions
│   │   │           ├── [Smart Shuffle] [Recent] [Favorites] [Downloads] [Settings]
│   │   │
│   │   ├── SliverToBoxAdapter → Section: Continue Listening
│   │   │   └── HorizontalCardList
│   │   │       └── ContinueListeningCard (art, title, subtitle, progress bar)
│   │   │
│   │   ├── SliverToBoxAdapter → Section: Recently Added
│   │   │   └── HorizontalCardList
│   │   │       └── AlbumCard (art, title, artist)
│   │   │
│   │   ├── SliverToBoxAdapter → Section: Most Played
│   │   │   └── HorizontalCardList
│   │   │       └── TrackCard (rank, art, title, artist, play count)
│   │   │
│   │   ├── SliverToBoxAdapter → Section: Quick Access
│   │   │   └── Wrap (2x2 grid of glass shortcut cards)
│   │   │       └── QuickAccessCard (icon, label, gradient bg)
│   │   │
│   │   ├── SliverToBoxAdapter → Section: Moods
│   │   │   └── HorizontalCardList
│   │   │       └── MoodCircle (96dp circle, icon, label)
│   │   │
│   │   ├── SliverToBoxAdapter → Section: Your Artists
│   │   │   └── HorizontalCardList
│   │   │       └── ArtistCard (circular, name)
│   │   │
│   │   ├── SliverToBoxAdapter → Section: Your Albums
│   │   │   └── ResponsiveGrid
│   │   │       └── AlbumCard (square, title, artist)
│   │   │
│   │   ├── SliverToBoxAdapter → Section: Genres
│   │   │   └── ResponsiveGrid (2xN phone, 3xN tablet)
│   │   │       └── GenreCard (gradient bg, icon, label)
│   │   │
│   │   ├── SliverToBoxAdapter → Section: Recently Played
│   │   │   └── VerticalList
│   │   │       └── TrackListTile (art, title, artist, time)
│   │   │
│   │   └── SliverToBoxAdapter → Section: Recommended
│   │       └── HorizontalCardList
│   │           └── AlbumCard (art, title, artist, "Recommended" badge)
│   │
│   ├── bottomNavigationBar: PremiumBottomNav
│   └── MiniPlayer (overlay, above bottom nav)
│
└── Providers
    ├── homeFeedProvider (AsyncNotifier)
    ├── continueListeningProvider
    ├── recentlyAddedProvider
    ├── mostPlayedProvider
    ├── recentlyPlayedProvider
    ├── favoriteSongsProvider
    ├── artistsProvider
    ├── albumsProvider
    └── genresProvider
```

---

##  Hero Header Design

```
┌──────────────────────────────────────────────────────────┐
│  [Animated Gradient Background]                           │
│  Colors shift: primary → tertiary → secondary (8s loop)  │
│  Subtle particle overlay (floating musical notes)         │
│                                                           │
│     "Good evening"                          [Avatar 36dp] │
│     displayLarge, white                                   │
│                                                           │
│     ┌──────────────────────────────────────────────┐     │
│     │  🔍  What do you want to listen to?          │     │
│     │  (glass search bar, 48dp, 16dp radius)       │     │
│     └──────────────────────────────────────────────┘     │
│                                                           │
│     ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐      │
│     │ ▶ Shf│ │ ⏱ Rc │ │ ♡ Fav│ │ ⬇ Dwn│ │ ⚙ Set│     │
│     │ uffle│ │ ent  │ │ orite│ │ load │ │tings │     │
│     └──────┘ └──────┘ └──────┘ └──────┘ └──────┘      │
│                                                           │
└──────────────────────────────────────────────────────────┘

Height: 340dp (expanded), collapses to 120dp on scroll
Background: AnimatedBuilder with 8s gradient rotation
  colors: [primary, tertiary, secondary, primary]
  begin: topLeft, end: bottomRight
  Slow sine wave on color stops (0.3 → 0.7 → 0.3)

Parallax: hero content moves at 0.5x scroll speed
Blur: bottom 40dp has glass gradient fade to content
```

---

##  Animation System

### 1. Hero Gradient Shift

```
Trigger:    Always active
Duration:   8s loop
Animation:  LinearGradient colors cycle through palette
            Colors smoothly interpolate (HSL shift)
Effect:     Background feels alive without being distracting

Implementation:
  AnimatedBuilder(
    animation: _gradientController,
    builder: (context, child) {
      final t = _gradientController.value;
      final color1 = Color.lerp(purple, pink, sin(t * pi));
      final color2 = Color.lerp(pink, amber, sin(t * pi + 0.3));
      return Container(
        gradient: LinearGradient(
          colors: [color1!, color2!, darkBg],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    },
  );
```

### 2. Staggered Section Entry

```
Trigger:    Page first load
Duration:   800ms total, 100ms per section stagger
Animation:  Each section fades up (y: 30 → 0) + opacity 0 → 1

Implementation:
  // Use AnimationController with Interval
  for (i, section) in sections:
    AnimationController(0.8s)
    Interval(i * 0.1, 0.3 + i * 0.1)
    FadeTransition + SlideTransition

Effect:     Sections cascade into view like a curtain rising
```

### 3. Card Hover / Press

```
Trigger:    Tap down
Duration:   150ms
Animation:  Scale 1.0 → 0.97 (spring, easeOut)
            Shadow elevates from SM to MD
Effect:     Physical button feel — card depresses under finger

Trigger:    Hover (desktop)
Duration:   300ms
Animation:  Scale 1.0 → 1.03, y-offset -4dp
            Shadow elevates from SM to LG
            Glow: 10px primary color behind card
```

### 4. Horizontal Scroll Snap

```
Trigger:    User scrolls horizontally
Behavior:   Snap-to-center with 24px peek of next card
            Cards are 140px wide (phone), 180px (tablet)
Effect:     Browsing feels curated, not overwhelming

Implementation:
  PageView(
    scrollDirection: Axis.horizontal,
    controller: PageController(viewportFraction: 0.45),
  );
```

### 5. Continue Listening Progress Bar

```
Trigger:    Playback position update
Animation:  Width animates smoothly from 0 → 1 (60fps)
            Gradient fill: primary → secondary
            Bar height: 3dp, pill-shaped
Effect:     Visual connection to current playback state
```

### 6. Quick Action Pop

```
Trigger:    Hero enters view
Duration:   400ms total, 60ms stagger per button
Animation:  Scale 0 → 1 + fade 0 → 1
            Slight bounce (easeOutBack)
Effect:     Buttons explode outward from center like a splash
```

---

##  Responsive Layout Strategy

```dart
// Phone (< 600dp)
// ─────────────────────
// Sections: all horizontal scroll (single row)
// Grids: 2 columns
// Hero: 340dp → 120dp collapsed

// Tablet (600-840dp)
// ─────────────────────
// Sections: 2 rows for grids
// Hero: 400dp → 160dp collapsed
// Side bar: optional navigation rail

// Desktop (> 840dp)
// ─────────────────────
// Max content width: 1024dp, centered
// Grids: 4 columns
// Side bar: fixed navigation rail (72dp)
// Content area has 48dp padding
```

---

##  Data Flow

```dart
// Each section is independently loaded via Riverpod family providers

class HomeFeedData {
  final List<Song> continueListening;
  final List<Song> recentlyAdded;
  final List<Song> mostPlayed;
  final List<Song> recentlyPlayed;
  final List<Song> favoriteSongs;
  final List<Artist> topArtists;
  final List<Album> topAlbums;
  final List<Genre> genres;
  final List<Mood> moods;
}

// Provider
@riverpod
class HomeFeed extends _$HomeFeed {
  @override
  Future<HomeFeedData> build() async {
    final repo = ref.read(musicRepositoryProvider);
    return HomeFeedData(
      continueListening: await repo.getContinueListening(),
      recentlyAdded: await repo.getRecentlyAdded(limit: 10),
      mostPlayed: await repo.getMostPlayed(limit: 10),
      recentlyPlayed: await repo.getRecentlyPlayed(limit: 10),
      favoriteSongs: await repo.getFavorites(),
      topArtists: await repo.getAllArtists(),
      topAlbums: await repo.getAllAlbums(),
      genres: await repo.getAllGenres(),
      moods: Mood.defaultMoods,
    );
  }
}

// Scroll position tracking for hero collapse
final scrollOffsetProvider = StateProvider<double>((ref) => 0);
```

---

##  New Widgets Required

| Widget | File | Purpose |
|--------|------|---------|
| `HomePage` | `home_page.dart` | Main screen scaffold with scroll + mini-player |
| `HeroHeader` | `hero_header.dart` | Animated gradient + greeting + search + quick actions |
| `AnimatedGradientBackground` | `hero_header.dart` | 8s color-shifting gradient |
| `QuickActions` | `quick_actions.dart` | Row of 5 glass shortcut buttons |
| `HomeSection` | `home_section.dart` | Reusable "Title → See All" + horizontal scroll |
| `HorizontalCardList` | `horizontal_card_list.dart` | Snap-to-center PageView of cards |
| `ContentGrid` | `content_grid.dart` | Responsive grid (2/3/4 columns) |
| `ContinueListeningCard` | `continue_listening_card.dart` | Progress bar card |
| `MoodCircle` | `mood_section.dart` | 96dp circular mood button |
| `GenreCard` | `genre_grid.dart` | Rounded gradient genre tile |
| `QuickAccessCard` | `quick_access_card.dart` | Glass shortcut card |
| `HomeProvider` | `home_provider.dart` | State management |
