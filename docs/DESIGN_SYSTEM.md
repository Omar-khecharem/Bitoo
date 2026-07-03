# BITOO Design System

> Minimal Luxury · Glassmorphism · Micro-Motion · Premium Audio Experience

---

## Design Philosophy

BITOO's design language is **Minimal Luxury** — the visual equivalent of a
high-end audio brand (Bang & Olufsen, McIntosh, Devialet). Every pixel serves a
purpose. White space is a feature, not a bug. Materials feel physical: frosted
glass, soft light, deep shadow.

| Principle | Application |
|-----------|-------------|
| **Subtraction** | Remove until only essence remains |
| **Depth** | Glassmorphism layers create physical hierarchy |
| **Motion** | Every transition tells a story (0.3s ease-out) |
| **Sound** | UI breathes with audio — reactive waveforms |
| **Craft** | 8px grid, 4dp corner minimum, meticulous alignment |

### Why Glassmorphism?

Glassmorphism creates **visual depth on screen**. In a music app, this mimics
the physical experience of holding a device playing music — the album art glows
through a frosted interface. This emotional connection elevates BITOO above
flat-design competitors like Spotify.

---

##  Color System

### Brand Palette

```
┌─────────────────────────────────────────────────────────────────────┐
│  PRIMARY (Purple Haze)      SECONDARY (Amber)     TERTIARY (Rose)   │
│                                                                      │
│  50  #F5F3FF                 50  #FFFBEB             50  #FFF1F2     │
│  100 #EDE9FE                100 #FEF3C7             100 #FFE4E6     │
│  200 #DDD6FE                200 #FDE68A             200 #FECDD3     │
│  300 #C4B5FD                300 #FCD34D             300 #FDA4AF     │
│  400 #A78BFA                400 #FBBF24             400 #FB7185     │
│  500 #8B5CF6 ◄── PRIMARY    500 #F59E0B ◄── ACCENT  500 #F43F5E     │
│  600 #7C3AED                600 #D97706             600 #E11D48     │
│  700 #6D28D9                700 #B45309             700 #BE123C     │
│  800 #5B21B6                800 #92400E             800 #9F1239     │
│  900 #4C1D95                900 #78350F             900 #881337     │
└─────────────────────────────────────────────────────────────────────┘
```

**Why Purple?** Purple is the color of creativity and luxury. Unlike Spotify's
functional green or Apple Music's red, purple communicates sophistication,
depth, and emotional resonance — perfect for a premium music experience.

### Dark Mode Colors

```dart
// Background hierarchy creates depth through luminance
// Each layer is slightly lighter, creating a stacking effect

Color background        = const Color(0xFF0A0A0F);  // Base — deepest black-blue
Color surfaceDark       = const Color(0xFF12121A);  // Card surface
Color surface           = const Color(0xFF1C1C26);  // Elevated surface
Color surfaceLight      = const Color(0xFF262633);  // Interactive elements

// Glass tokens (used via backdropFilter)
Color glassBg           = const Color(0x1AFFFFFF);  // 10% white
Color glassBorder       = const Color(0x26FFFFFF);  // 15% white
Color glassStrong       = const Color(0x33FFFFFF);  // 20% white (nav bars)
Color glassHover        = const Color(0x0DFFFFFF);  // 5% white (hover state)

// Text hierarchy
Color textPrimary       = const Color(0xFFF5F5F7);  // Nearly white — high emphasis
Color textSecondary     = const Color(0xFFA1A1AA);  // Medium emphasis — subtle
Color textTertiary      = const Color(0xFF52525B);  // Low emphasis — hints

// Semantic
Color error             = const Color(0xFFF43F5E);  // Rose-500
Color success           = const Color(0xFF10B981);  // Emerald-500
Color warning           = const Color(0xFFF59E0B);  // Amber-500
Color info              = const Color(0xFF3B82F6);  // Blue-500
```

### Light Mode Colors

```dart
Color background        = const Color(0xFFF8F8FA);  // Warm off-white
Color surfaceDark       = const Color(0xFFF0F0F5);  // Light gray surface
Color surface           = const Color(0xFFFFFFFF);  // White
Color surfaceLight      = const Color(0xFFFAFAFA);  // Near white

// Glass (light mode — more opaque)
Color glassBg           = const Color(0xE6FFFFFF);  // 90% white
Color glassBorder       = const Color(0x1A000000);  // 10% black

// Text
Color textPrimary       = const Color(0xFF18181B);  // Near black
Color textSecondary     = const Color(0xFF71717A);  // Medium gray
Color textTertiary      = const Color(0xFFA1A1AA);  // Light gray
```

### Gradients

```dart
// Primary gradient — used for hero sections, buttons
LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Premium gradient — featured content, premium badges
LinearGradient premiumGradient = LinearGradient(
  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFFF59E0B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 0.5, 1.0],
);

// Glass overlay gradient — for album art reflections
LinearGradient glassOverlay = LinearGradient(
  colors: [Colors.transparent, Color(0x40000000)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// Button hover gradient (animated)
LinearGradient hoverGradient = LinearGradient(
  colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
);
```

---

##  Typography

### Font Selection

| Role | Font | Weight | Why |
|------|------|--------|-----|
| **Display / Headlines** | [Outfit](https://fonts.google.com/specimen/Outfit) | Bold (700), SemiBold (600) | Geometric precision with warm curves. Feels modern, architectural, and premium — like a Bang & Olufsen product. |
| **Body / UI / Labels** | [Inter](https://fonts.google.com/specimen/Inter) | Regular (400), Medium (500) | Best-in-class readability at every size. Optimized for screens. The Helvetica of the digital age. |
| **Numbers / Stats** | Inter | Medium (500) | Tabular figures align perfectly in player counters. |
| **Serif (Editorial)** | [Fraunces](https://fonts.google.com/specimen/Fraunces) | Soft (400), Semibold (600) | Optional for featured editorial content, artist stories, playlist descriptions. Adds warmth. |

**Why Outfit + Inter?** Spotify uses Circular (custom). Apple Music uses SF Pro
(custom). Outfit + Inter is our open-source equivalent — distinctive enough to
be memorable, refined enough to feel bespoke.

### Type Scale

```dart
// ─── Display ─── (Used once per screen — hero moments)
TextStyle displayLarge = TextStyle(        // Welcome screen, featured album
  fontFamily: 'Outfit',
  fontWeight: FontWeight.w700,             // Bold
  fontSize: 52,
  height: 1.1,                             // 57.2px → 57px
  letterSpacing: -1.5,
);

TextStyle displayMedium = TextStyle(       // Section hero titles
  fontFamily: 'Outfit',
  fontWeight: FontWeight.w700,
  fontSize: 40,
  height: 1.1,
  letterSpacing: -1.0,
);

// ─── Headlines ───
TextStyle headlineLarge = TextStyle(       // Page titles
  fontFamily: 'Outfit',
  fontWeight: FontWeight.w600,             // SemiBold
  fontSize: 32,
  height: 1.2,                             // 38.4px → 38px
  letterSpacing: -0.5,
);

TextStyle headlineMedium = TextStyle(      // Section titles
  fontFamily: 'Outfit',
  fontWeight: FontWeight.w600,
  fontSize: 28,
  height: 1.2,
  letterSpacing: -0.3,
);

TextStyle headlineSmall = TextStyle(       // Card titles, playlist names
  fontFamily: 'Outfit',
  fontWeight: FontWeight.w600,
  fontSize: 24,
  height: 1.3,
  letterSpacing: -0.2,
);

// ─── Titles ───
TextStyle titleLarge = TextStyle(          // Track names, album titles
  fontFamily: 'Outfit',
  fontWeight: FontWeight.w600,
  fontSize: 20,
  height: 1.3,
  letterSpacing: -0.2,
);

TextStyle titleMedium = TextStyle(         // List item titles
  fontFamily: 'Outfit',
  fontWeight: FontWeight.w500,             // Medium
  fontSize: 16,
  height: 1.4,
  letterSpacing: -0.1,
);

TextStyle titleSmall = TextStyle(          // Small item titles
  fontFamily: 'Outfit',
  fontWeight: FontWeight.w500,
  fontSize: 14,
  height: 1.4,
  letterSpacing: -0.1,
);

// ─── Body ───
TextStyle bodyLarge = TextStyle(           // Paragraphs, descriptions
  fontFamily: 'Inter',
  fontWeight: FontWeight.w400,
  fontSize: 16,
  height: 1.6,                             // 25.6px → excellent readability
  letterSpacing: 0.0,
);

TextStyle bodyMedium = TextStyle(          // Secondary text, metadata
  fontFamily: 'Inter',
  fontWeight: FontWeight.w400,
  fontSize: 14,
  height: 1.5,
  letterSpacing: 0.0,
);

TextStyle bodySmall = TextStyle(           // Captions, timestamps
  fontFamily: 'Inter',
  fontWeight: FontWeight.w400,
  fontSize: 12,
  height: 1.5,
  letterSpacing: 0.0,
);

// ─── Labels ───
TextStyle labelLarge = TextStyle(          // Buttons, tabs, chips
  fontFamily: 'Inter',
  fontWeight: FontWeight.w500,             // Medium
  fontSize: 14,
  height: 1.4,
  letterSpacing: 0.5,                      // 0.5px tracking = premium feel
);

TextStyle labelMedium = TextStyle(         // Small buttons, badges
  fontFamily: 'Inter',
  fontWeight: FontWeight.w500,
  fontSize: 12,
  height: 1.4,
  letterSpacing: 0.4,
);

TextStyle labelSmall = TextStyle(          // Tiny labels, timestamps
  fontFamily: 'Inter',
  fontWeight: FontWeight.w500,
  fontSize: 11,
  height: 1.4,
  letterSpacing: 0.3,
);
```

### Line Length Rule

Maximum line length for body text: **66 characters** (emergency break at 80).

```dart
// In practice: constrain body text containers
SizedBox(
  width: 640,  // Max comfortable reading width
  child: Text('...', style: theme.textTheme.bodyLarge),
);
```

---

##  Spacing System

### 8px Grid (4px Micro)

| Token | Value | Usage |
|-------|-------|-------|
| `spaceXXS` | 2 | Icon padding inside buttons |
| `spaceXS` | 4 | Micro spacing between elements |
| `spaceSM` | 8 | Tight spacing, icon gaps |
| `spaceMD` | 12 | Related content groups |
| `spaceLG` | 16 | Standard padding, card insets |
| `spaceXL` | 24 | Section spacing |
| `space2XL` | 32 | Page margins, large sections |
| `space3XL` | 48 | Screen edge margins |
| `space4XL` | 64 | Hero section padding |
| `space5XL` | 96 | Massive white space |

```dart
class Spacing {
  static const double xxs = 2;
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 24;
  static const double xxl = 32;
  static const double x3l = 48;
  static const double x4l = 64;
  static const double x5l = 96;
}
```

### Layout Grid

```dart
// Page horizontal padding
EdgeInsets pagePadding = EdgeInsets.symmetric(
  horizontal: Spacing.xl,  // 24 — standard
  // Tablet: 48, Desktop: 64
);

// Card grid
// Phone: 2 columns, Tablet: 3-4 columns, Desktop: 5-6 columns
SliverGrid(
  delegate: SliverChildBuilderDelegate(...),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: breakpoint == Breakpoint.phone ? 2 : 3,
    crossAxisSpacing: Spacing.lg,   // 16
    mainAxisSpacing: Spacing.lg,    // 16
    childAspectRatio: 1,            // Square album art
  ),
);
```

---

##  Elevation & Shadows

### Shadow System

```dart
// Every shadow is a physical metaphor — light from top-left

class AppShadows {
  // Subtle — for cards on surfaces
  static List<BoxShadow> shadowSM = [
    BoxShadow(
      color: Color(0x0A000000),  // 4% opacity
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x05000000),  // 2% opacity
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // Medium — for elevated cards, dialogs
  static List<BoxShadow> shadowMD = [
    BoxShadow(
      color: Color(0x0F000000),  // 6% opacity
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x08000000),  // 3% opacity
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // Large — for modals, bottom sheets
  static List<BoxShadow> shadowLG = [
    BoxShadow(
      color: Color(0x14000000),  // 8% opacity
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000),  // 4% opacity
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // Premium glow — for primary buttons, active states
  static List<BoxShadow> glowPrimary = [
    BoxShadow(
      color: Color(0x408B5CF6),  // Primary with 25%
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x208B5CF6),  // Primary with 12%
      blurRadius: 40,
      offset: Offset(0, 8),
    ),
  ];

  // Glass shadow — for frosted elements
  static List<BoxShadow> shadowGlass = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];
}
```

### Corner Radius

```dart
class AppRadius {
  static const double xs   = 4;   // Chips, badges
  static const double sm   = 8;   // Small cards
  static const double md   = 12;  // Standard cards
  static const double lg   = 16;  // Large cards, dialogs
  static const double xl   = 20;  // Bottom sheets
  static const double xxl  = 24;  // Player page
  static const double full = 999; // Pill shapes
}
```

**Why rounded corners?** Generous radii feel softer, more approachable, and
more luxurious. Sharp corners feel aggressive and cheap. 12-16dp is the sweet
spot where cards feel intentional, not accidental.

---

##  Glassmorphism System

### Glass Component Pattern

```dart
class GlassWidget extends StatelessWidget {
  const GlassWidget({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.lg,
    this.opacity = 0.1,        // 10% white for dark mode
    this.blur = 20,
    this.borderOpacity = 0.15, // 15% white border
  });

  // ─── Implementation ───
  // ClipRRect + BackdropFilter (ImageFilter.blur)
  //   └── Container (semi-transparent background)
  //     └── Container (subtle border)
  //       └── child

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            border: Border.all(
              color: Colors.white.withOpacity(borderOpacity),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

### Glass Intensity Levels

| Level | Opacity | Blur | Use Case |
|-------|---------|------|----------|
| Subtle | 5% | 30px | Background cards, album art backdrop |
| Medium | 10% | 20px | Standard glass cards (default) |
| Strong | 15% | 15px | Navigation bars, sticky headers |
| Heavy | 20% | 10px | Active states, pressed buttons |

---

##  Component Library

### 1. Button System

#### Primary Button

```dart
class PrimaryButton extends StatefulWidget {
  // Properties
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;  // sm, md, lg

  // ─── States ───
  // Default:       Primary gradient + subtle glow
  // Hover:         Brighter gradient, shadow elevates
  // Pressed:       Scale 0.98, opacity shift
  // Disabled:      40% opacity, no glow
  // Loading:       Shimmer overlay, icon spins
}

// Size variants
// LG: height 56, padding 24h, radius 16, labelLarge
// MD: height 48, padding 20h, radius 14, labelLarge
// SM: height 40, padding 16h, radius 12, labelMedium
```

#### Secondary Button (Glass)

```dart
class SecondaryButton extends StatelessWidget {
  // Glass background, subtle border, text in textPrimary
  // Hover: glass becomes more opaque
  // Pressed: scale 0.98
}
```

#### Icon Button (Premium Circle)

```dart
class PremiumIconButton extends StatelessWidget {
  // 48x48 circular glass button
  // Background: glass at 10%
  // Border: 0.5px at 15%
  // Icon: textSecondary (changes to primary on active)
  // Hover: background becomes 15%
}
```

#### Text Button

```dart
class PremiumTextButton extends StatelessWidget {
  // Minimal — no background, no border
  // Color: textSecondary (default), primary (hover/active)
  // Underline appears on hover
}
```

### 2. Bottom Navigation

```dart
// ─── Glass Bottom Navigation Bar ───
// Height: 72dp (tall enough for premium feel)
// Background: Heavy glass (20% white, 15px blur)
// Top border: 0.5px glassBorder
// Corner radius: 20dp top-left + top-right
// Padding: 8dp top, 16dp bottom (safe area)
// Inner margin: 16dp horizontal

// Tab layout: evenly spaced, 5 tabs max
// Active: icon filled + primary color + label appears
// Inactive: icon outlined + textTertiary + no label

// Icon size: 24dp (active), 22dp (inactive)
// Active indicator: subtle glass pill behind icon

// Animation: spring curve (0.3s) on icon change
// No text labels on inactive tabs — cleaner
```

### 3. Top Navigation / App Bar

```dart
// ─── Premium App Bar ───
// Height: 64dp (standard)
// No bottom border (clean)
// Background: glass 10%, blur 20px (only when scrolled)
// Initial state: fully transparent background
// Scroll threshold: 40px before glass appears
// Back button: PremiumIconButton (circular glass)

// Title: headlineSmall, SemiBold
// Actions: max 2 icon buttons

// Large title variant (home screen):
//   Title at 48dp from top, headlineLarge size
//   Collapses to standard 64dp as user scrolls
```

### 4. Search Bar

```dart
// ─── Premium Search Bar ───
// Height: 52dp
// Background: glass (10%, blur 20px)
// Border: 1dp, glassBorder
// Radius: 16dp
// Left icon: search (20dp, textTertiary)
// Text: bodyLarge
// Placeholder: textTertiary
// Clear button appears on typing
// Right icon: filter/mic option

// Active state:
//   Border brightens to primary (40%)
//   Glass opacity increases to 15%
//   Shadow: glowPrimary (subtle)

// Micro-animation:
//   On focus: scale 1.02 with spring curve
//   On blur: scale 1.0
```

### 5. Cards

#### Album Card

```dart
class AlbumCard extends StatelessWidget {
  // Size: square (width matches grid column)
  // Corner radius: 12dp
  // Image: rounded, full-bleed
  // No border overlay on image (clean)
  // Bottom inset: 12dp padding
  // Title: titleSmall (Outfit, Medium, 1 line)
  // Subtitle: bodySmall (Inter, Regular, textTertiary, 1 line)
  // No shadow on image — shadow goes on card wrapper

  // Hover/Pressed:
  //   Scale: 1.02 (spring, 0.3s)
  //   Shadow: elevates from SM to MD
  //   Glass overlay appears: 10% black gradient from bottom
  //   Play button (glass circle) fades in at center
}
```

#### Artist Card

```dart
class ArtistCard extends StatelessWidget {
  // Portrait layout (3:4 aspect ratio preferred)
  // Image: circular crop (radius: full)
  // Image size: 120dp (list), 160dp (grid)
  // Border: 2dp transparent (adds definition against backgrounds)
  // Name: titleSmall, centered below image
  // Followers: bodySmall, textTertiary, centered
  // No border radius on card itself — only image is circular

  // Interactive: same scale + shadow as AlbumCard
  // On image: no play button overlay (artist is not playable)
  // On tap: navigate to artist page
}
```

#### Playlist Card

```dart
class PlaylistCard extends StatelessWidget {
  // Square, 12dp radius
  // Image full-bleed
  // Gradient overlay at bottom: transparent → 60% black, 48dp
  // Title overlay: titleMedium, white, 2 lines max
  // Track count: bodySmall, textTertiary, 1 line
  // Creator avatar: 20dp circle, positioned top-right

  // Interactive: scale + play button on hover
}
```

### 6. Player Controls

```dart
// ─── Mini Player (Bottom) ───
// Height: 64dp
// Background: glassStrong (20%, 15px blur)
// No corner radius (full width)
// Top border: 0.5px glassBorder

// Layout:
//   [Album Art (48dp sq, 8dp radius)] [Title/Artist] [Play] [Skip]
//   Left: album art + text (flex: 3)
//   Right: controls (flex: 2)

// Progress indicator: thin line (2dp) at top of mini-player
// Color: primaryGradient
// Animation: smooth linear (60fps update)

// ─── Full Player ───
// Background: album art scaled + heavily blurred (40px)
// Overlay: glassOverlay gradient (top transparent → bottom 80% black)
// Content: centered vertically

// Album art: 280dp square, 20dp radius
// Shadow: xl glow around album art (primary color, 60px blur)

// Track name: headlineSmall, white
// Artist name: bodyLarge, textSecondary

// Progress bar: SliderTheme with custom track shape
//   Track height: 4dp
//   Track color: textTertiary (30%)
//   Active track: primaryGradient
//   Thumb: 12dp white circle with primary glow
//   Thumb on drag: expands to 16dp

// Controls row: evenly spaced
//   Shuffle (22dp)
//   Previous (24dp)
//   Play/Pause (56dp — large, glass circle, primary icon)
//   Next (24dp)
//   Repeat (22dp)

// Volume: horizontal slider, identical to progress bar
// Queue button: top right, icon: list
// Like button: heart icon, fills on active
```

### 7. Dialogs

```dart
// ─── Premium Dialog ───
// Background: glassStrong (20%, 15px blur)
// Radius: 20dp
// Width: max 360dp (centered)
// Shadow: shadowLG
// No title bar (clean)
// Padding: 24dp

// Icon: 48dp circle at top (optional)
// Title: titleLarge
// Description: bodyMedium, textSecondary
// Actions: horizontal, aligned right
// Button spacing: 12dp
// Dismiss: tap outside (optional)

// Animation: scale 0.9 → 1.0 + fade 0 → 1 (spring 0.35s)
// Overlay background: 60% black
```

### 8. Snackbars

```dart
// ─── Premium Snackbar ───
// Position: top (not bottom) — more visible, premium pattern
// Background: glassStrong (20%, 15px blur)
// Radius: 14dp
// Padding: 16dp h, 12dp v
// Max width: 400dp, centered
// Shadow: shadowMD
// Icon: 20dp (semantic color)
// Text: bodyMedium
// Action: textButton, compact
// Duration: 4s (auto-dismiss)
// Swipe to dismiss

// Animation: slide down + fade (0.35s, ease-out)
// Success: emerald icon + border
// Error: rose icon + border
// Info: blue icon + border
```

### 9. Loading States & Skeleton

```dart
// ─── Shimmer Loading ───
// Base color: surface (1C1C26)
// Highlight color: surfaceLight (262633)
// Animation: gradient sweep left → right (1.5s loop)

// Album card skeleton:
//   Square box: 12dp radius, shimmer fill
//   Text line 1: 80% width, bodyMedium height
//   Text line 2: 50% width, bodySmall height

// Artist card skeleton:
//   Circle: 120dp, shimmer fill
//   Text line 1: 60% width, centered
//   Text line 2: 40% width, centered

// List tile skeleton:
//   48dp square (left) + 2 text lines (right)

// Full page skeleton:
//   Hero banner: 200dp height, full width
//   Grid of 4 album card skeletons
//   Section header: 40% width line
//   Horizontal row of 3 card skeletons
```

### 10. Empty States

```dart
// ─── Premium Empty State ───
// Centered content, 60% width (max 320dp)
// Icon: 80dp, custom illustration (not emoji)
//   Style: line art + single gradient accent
// Title: headlineSmall
// Description: bodyMedium, textSecondary
// Action: PrimaryButton (optional)

// Variants:
//   Library empty: "Your library is quiet" + "Add your first track"
//   Search no results: "No results found" + "Try a different search"
//   Playlist empty: "Curate your first playlist"
//   Downloads empty: "Download music for offline playback"
//   Queue empty: "Queue is empty" + "Add tracks from your library"
```

### 11. Error States

```dart
// ─── Premium Error State ───
// Same layout as empty state
// Icon: 80dp, error-themed illustration
// Title: "Something went wrong"
// Description: user-friendly message (not technical)
// Action: "Try Again" (PrimaryButton)
// No stack traces in UI

// Offline variant:
//   Icon: cloud-off illustration
//   Title: "You're offline"
//   Description: "Play from your downloads or connect to the internet"
//   Action: "Go to Downloads" (SecondaryButton)
```

---

##  Animation System

### Motion Principles

| Principle | Application |
|-----------|-------------|
| **Spring physics** | Natural-feeling motion (not linear) |
| **Stagger** | Elements enter in sequence, not simultaneously |
| **Purpose** | Every animation guides attention or explains hierarchy |
| **Duration** | 300ms standard, 500ms for hero transitions |
| **Easing** | `easeInOutCubic` for UI, `spring` for interactive |
| **Displacement** | Never exceed 50% of element size |

### Timing Constants

```dart
class AppDurations {
  // Micro-interactions (button press, hover)
  static const Duration micro = Duration(milliseconds: 150);

  // Standard transitions (pages, dialogs)
  static const Duration standard = Duration(milliseconds: 300);

  // Complex transitions (hero, full-screen player)
  static const Duration complex = Duration(milliseconds: 500);

  // Shimmer sweep duration
  static const Duration shimmer = Duration(milliseconds: 1500);

  // Snackbar display
  static const Duration snackbar = Duration(seconds: 4);

  // Debounce / throttle
  static const Duration debounce = Duration(milliseconds: 300);
}
```

### Micro-Interactions

| Element | Trigger | Animation | Duration | Curve |
|---------|---------|-----------|----------|-------|
| Button | Press | Scale 1.0 → 0.97 | 100ms | easeOut |
| Button | Release | Scale 0.97 → 1.0 | 200ms | spring |
| Card | Tap | Scale 1.0 → 1.02 | 300ms | spring |
| Icon | State change | Rotate + color | 300ms | easeInOut |
| Switch | Toggle | Thumb slide + bg | 200ms | spring |
| Slider | Drag | Thumb scale up | 100ms | easeOut |
| Page | Enter | Fade up (0 → 1, y: 20 → 0) | 300ms | easeOutCubic |
| Dialog | Appear | Scale 0.9 → 1.0 + fade | 350ms | spring |
| Bottom sheet | Appear | Slide up | 300ms | easeOutCubic |
| Snackbar | Appear | Slide down + fade | 350ms | easeOutCubic |
| Like | Tap | Heart bounce + color pop | 400ms | spring |
| Playlist | Add item | Slide in + fade | 300ms | easeOut |

### Page Transition

```dart
// Push: new page slides up from bottom (like a music note rising)
// Pop: page slides down (gravity simulation)
// Hero: album art flies from card → full player (shared axis)

CustomTransitionPage(
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    final tween = Tween<Offset>(
      begin: Offset(0, 0.1),  // Start 10% below
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic));

    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  },
  transitionDuration: AppDurations.standard,
);
```

---

##  Icon Strategy

### Primary Icon Library: Phosphor Icons

[Phosphor Icons](https://phosphoricons.com/) — the most premium open-source
icon set available. Features 4 weights (thin, light, regular, fill).

| Weight | Usage | Example |
|--------|-------|---------|
| **Thin** | Decorative, large hero elements | Player screen icons |
| **Light** | Tab bar, navigation (inactive) | Bottom nav icons |
| **Regular** | Standard UI actions | Buttons, menus |
| **Fill** | Active states, emphasis | Active tab, liked |

### Icon Sizing

```dart
class AppIconSizes {
  static const double micro  = 16;  // Inline, badges
  static const double small  = 20;  // Context menu items
  static const double medium = 24;  // Standard action icons
  static const double large  = 28;  // Nav bar (active)
  static const double xl     = 32;  // Featured actions
  static const double xxl    = 48;  // Hero icons (empty states)
  static const double xxxl   = 80;  // Illustrations
}
```

### Specific Icon Mapping

| Action | Icon (Phosphor) | Weight |
|--------|-----------------|--------|
| Home | `PhosphorIcons.house()` | Light / Fill |
| Search | `PhosphorIcons.magnifyingGlass()` | Light |
| Library | `PhosphorIcons.books()` | Light |
| Play | `PhosphorIcons.playCircle()` | Fill |
| Pause | `PhosphorIcons.pauseCircle()` | Fill |
| Next | `PhosphorIcons.skipForward()` | Fill |
| Previous | `PhosphorIcons.skipBack()` | Fill |
| Shuffle | `PhosphorIcons.shuffle()` | Regular |
| Repeat | `PhosphorIcons.arrowsClockwise()` | Regular |
| Heart (like) | `PhosphorIcons.heart()` | Regular / Fill |
| Download | `PhosphorIcons.downloadSimple()` | Regular |
| Queue | `PhosphorIcons.queue()` | Regular |
| Share | `PhosphorIcons.shareNetwork()` | Regular |
| More | `PhosphorIcons.dotsThreeVertical()` | Regular |
| Add | `PhosphorIcons.plus()` | Regular |
| Close | `PhosphorIcons.x()` | Regular |
| Back | `PhosphorIcons.caretLeft()` | Bold |
| Settings | `PhosphorIcons.gear()` | Regular |
| Equalizer | `PhosphorIcons.sliders()` | Regular |
| Volume | `PhosphorIcons.speakerHigh()` | Regular |
| Mute | `PhosphorIcons.speakerX()` | Regular |
| Check | `PhosphorIcons.check()` | Bold |
| Warning | `PhosphorIcons.warning()` | Regular |
| Error | `PhosphorIcons.xCircle()` | Regular |
| Empty | `PhosphorIcons.musicNotes()` | Thin / 80dp |

### Alternative: Lucide Icons

[Lucide Icons](https://lucide.dev/) — clean, consistent, and growing rapidly.
Slightly more minimalist than Phosphor. Excellent as a secondary set.

---

##  Screen Architecture

### Screen Layout Hierarchy

```
┌──────────────────────────────────────────────────────┐
│  Status Bar (transparent, content behind)             │
├──────────────────────────────────────────────────────┤
│  PremiumAppBar (glass on scroll, transparent static)  │
├──────────────────────────────────────────────────────┤
│                                                        │
│  ┌─── 24dp horizontal padding ──────────────────┐     │
│  │                                                │     │
│  │  Content Area                                   │     │
│  │  ┌────────────────────────────────────────┐     │     │
│  │  │  Grid / List / Hero content            │     │     │
│  │  └────────────────────────────────────────┘     │     │
│  │                                                │     │
│  └────────────────────────────────────────────────┘     │
│                                                        │
├──────────────────────────────────────────────────────┤
│  Mini Player (64dp glass bar, hidden when stopped)     │
├──────────────────────────────────────────────────────┤
│  PremiumBottomNav (72dp glass, 20dp top radius)        │
│  System Navigation Bar (transparent)                   │
└──────────────────────────────────────────────────────┘
```

### Screen-by-Screen Design

---

####   Splash Screen

```
┌──────────────────────────────────────────────────────┐
│                                                        │
│                                                        │
│                                                        │
│              ┌──────────────────────┐                  │
│              │                      │                  │
│              │      BITOO           │                  │
│              │    (animated logo)   │                  │
│              │                      │                  │
│              └──────────────────────┘                  │
│                                                        │
│                    "Experience Sound"                   │
│                    bodyMedium, textTertiary              │
│                                                        │
│                                                        │
│                                                        │
│              ┌──────────────────────┐                  │
│              │    Loading spinner   │                  │
│              │    (glass circle,    │                  │
│              │     primary pulse)   │                  │
│              └──────────────────────┘                  │
│                                                        │
│                                                        │
│                                                        │
│                                                        │
└──────────────────────────────────────────────────────┘

Background: pure black (#0A0A0F)
Animation: Logo fades in (0→1, 0.8s), then loading spinner
pulses (scale 1→1.1→1, 2s loop). After init completes,
crossfade to next screen (0.5s).
```

---

####   Onboarding Screen

```
┌──────────────────────────────────────────────────────┐
│                                                        │
│                                                        │
│              ┌──────────────────────────┐              │
│              │                          │              │
│              │   Illustration (80dp)    │              │
│              │   Phosphor icon, thin    │              │
│              │                          │              │
│              └──────────────────────────┘              │
│                                                        │
│              "High-Fidelity Audio"                      │
│              headlineMedium, centered                   │
│                                                        │
│     "Stream in lossless quality. Feel every note       │
│      with crystal clarity."                            │
│     bodyLarge, textSecondary, centered, 66ch max       │
│                                                        │
│                                                        │
│                                                        │
│              ┌──────────────────────┐                  │
│              │   Page indicator     │                  │
│              │   ● ○ ○ ○ (3 dots)   │                  │
│              └──────────────────────┘                  │
│                                                        │
│              ┌──────────────────────┐                  │
│              │   Continue           │                  │
│              │   PrimaryButton      │                  │
│              └──────────────────────┘                  │
│                                                        │
│              ┌──────────────────────┐                  │
│              │   Skip               │                  │
│              │   PremiumTextButton  │                  │
│              └──────────────────────┘                  │
│                                                        │
└──────────────────────────────────────────────────────┘

Background: primaryGradient (darkened, 80% black overlay)
Cards: glassMedium, 16dp radius
Dots: textTertiary (inactive), primary (active), spring scale
```

---

####   Auth Screen (Login/Register)

```
┌──────────────────────────────────────────────────────┐
│                                                        │
│  ┌───24dp─────────────────────────────────────────┐   │
│  │                                                  │   │
│  │  "Welcome back"                                  │   │
│  │  headlineLarge                                   │   │
│  │                                                  │   │
│  │  "Sign in to continue your journey"              │   │
│  │  bodyLarge, textSecondary                        │   │
│  │                                                  │   │
│  │  ┌──────────────────────────────────────────┐    │   │
│  │  │  Email                                    │    │   │
│  │  │  PremiumTextField (glass, 16dp radius)    │    │   │
│  │  └──────────────────────────────────────────┘    │   │
│  │                                                  │   │
│  │  ┌──────────────────────────────────────────┐    │   │
│  │  │  Password                                 │    │   │
│  │  │  PremiumTextField (glass, 16dp radius)    │    │   │
│  │  └──────────────────────────────────────────┘    │   │
│  │                                                  │   │
│  │  "Forgot password?" (textButton, right align)    │   │
│  │                                                  │   │
│  │  ┌──────────────────────────────────────────┐    │   │
│  │  │  Sign In                                  │    │   │
│  │  │  PrimaryButton, fullWidth                 │    │   │
│  │  └──────────────────────────────────────────┘    │   │
│  │                                                  │   │
│  │  ┌────┐  ┌────┐  ┌────┐                         │   │
│  │  │ G  │  │ A  │  │ X  │   Social login circles   │   │
│  │  └────┘  └────┘  └────┘   48dp glass circles     │   │
│  │                                                  │   │
│  │  "Don't have an account? Sign Up"                │   │
│  └──────────────────────────────────────────────────┘   │
│                                                        │
└──────────────────────────────────────────────────────┘

Background: album art collage (blurred 30px, opacity 30%)
TextFields: glass at 10%, border at 15%, focus = primary border
Social buttons: glass circles with brand colors on hover
```

---

####   Home Screen

```
┌────────────────────────────────────────────────────────┐
│  [Glass AppBar, transparent when at top]                │
│  "Good evening"          [settings] [notification]      │
│  headlineLarge                                          │
├────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Recently Played    → See All                     │   │
│  │  titleLarge                                       │   │
│  │                                                    │   │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐             │   │
│  │  │Album │ │Album │ │Album │ │Album │             │   │
│  │  │ Art  │ │ Art  │ │ Art  │ │ Art  │             │   │
│  │  │ Name │ │ Name │ │ Name │ │ Name │             │   │
│  │  └──────┘ └──────┘ └──────┘ └──────┘             │   │
│  │  (horiz. scroll, snap, 140px width cards)          │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Made for You    → See All                        │   │
│  │  titleLarge                                       │   │
│  │                                                    │   │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐             │   │
│  │  │Mix 1 │ │Mix 2 │ │Mix 3 │ │Mix 4 │             │   │
│  │  └──────┘ └──────┘ └──────┘ └──────┘             │   │
│  │  (horiz. scroll)                                   │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Trending    → See All                            │   │
│  │  titleLarge                                       │   │
│  │                                                    │   │
│  │  ┌──┐ ┌──────────┐ ┌──┐ ┌──────────┐             │   │
│  │  │#1│ │ Track    │ │#2│ │ Track    │             │   │
│  │  │  │ │ Artist   │ │  │ │ Artist   │             │   │
│  │  └──┘ └──────────┘ └──┘ └──────────┘             │   │
│  │  (vertical list, 64dp item height)                 │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
├────────────────────────────────────────────────────────┤
│  [Mini Player — hidden when stopped]                     │
│  [Bottom Nav — Home • Explore • Library • Search]        │
└────────────────────────────────────────────────────────┘

Section headers: titleLarge, with "See All" (labelLarge, textSecondary)
Horizontal scroll: snap-to-center, shows next card peek (24dp)
```

---

####   Explore Screen

```
┌────────────────────────────────────────────────────────┐
│  [Glass AppBar]                                         │
│  "Explore"                                              │
│  headlineLarge                                          │
├────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Search Bar (glass, 52dp, 16dp radius)            │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Genres                                            │   │
│  │                                                    │   │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐     │   │
│  │  │ Pop    │ │ Rock   │ │ Hip-Hop│ │ Jazz   │     │   │
│  │  │(purple)│ │(amber) │ │(rose)  │ │(blue)  │     │   │
│  │  └────────┘ └────────┘ └────────┘ └────────┘     │   │
│  │  (2x2 grid, rounded cards with gradient bg)        │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Moods & Activities                               │   │
│  │                                                    │   │
│  │  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐     │   │
│  │  │Foc │ │Work│ │Gym │ │Relx│ │Prt │ │Soc │     │   │
│  │  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘     │   │
│  │  (horizontal scroll, 96x96 circular glass)         │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Trending Near You    → See All                   │   │
│  │                                                    │   │
│  │  [Album Card row — horizontal scroll]              │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
├────────────────────────────────────────────────────────┤
│  [Mini Player]                                          │
│  [Bottom Nav]                                           │
└────────────────────────────────────────────────────────┘

Genre cards: 2x2 grid, aspect ratio 1:1, gradient background
+ icon + genre name. Unique gradient per genre.
Mood circles: 96dp circular glass buttons with mood icon + label below
```

---

####   Library Screen

```
┌────────────────────────────────────────────────────────┐
│  [Glass AppBar]                                         │
│  "Your Library"                              [+]        │
│  headlineLarge                                          │
├────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  [Playlists] [Albums] [Artists] [Downloaded]     │   │
│  │  (SegmentedControl — glass pills, 8dp radius)    │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Search in library (glass search bar, compact)    │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌── Sort: Recent ▾ ──── View: ▦ ▦ ────────────────┐   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  ┌──┐                                              │   │
│  │  │48│ Track Name                     Artist ▸     │   │
│  │  │px│ Album Name                    3:45 ▸       │   │
│  │  └──┘                                              │   │
│  ├──────────────────────────────────────────────────┤   │
│  │  [same layout — list of library items]            │   │
│  ├──────────────────────────────────────────────────┤   │
│  │  [list continues...]                              │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
├────────────────────────────────────────────────────────┤
│  [Mini Player]                                          │
│  [Bottom Nav]                                           │
└────────────────────────────────────────────────────────┘

SegmentedControl: glass pills, active = primary gradient + white text
List items: 56dp height, album art 40dp sq, track info, time
3-dot menu on right reveals PremiumContextMenu
```

---

####   Search Screen

```
┌────────────────────────────────────────────────────────┐
│  [No app bar — search bar is hero]                      │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  🔍 │ Artists, songs, or podcasts...         │ 🎤│  │
│  │  ──────────────────────────────────────────────── │  │
│  │  (Large search bar, 56dp, glass, 20dp radius)    │  │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  (Before typing — Browse Categories)                     │
│  ┌──────────────────────────────────────────────────┐   │
│  │  "Browse All"                                     │   │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐            │   │
│  │  │ Pop  │ │ Rock │ │HipHop│ │ Jazz │            │   │
│  │  └──────┘ └──────┘ └──────┘ └──────┘            │   │
│  │  (2x4 grid of category cards)                     │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  (After typing — Results)                                │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Top Result                                       │   │
│  │  ┌─────────────────────────────────────────┐     │   │
│  │  │ 128dp art │ Artist Name                 │     │   │
│  │  │           │ Artist, N followers         │     │   │
│  │  └─────────────────────────────────────────┘     │   │
│  │                                                    │   │
│  │  Songs                                             │   │
│  │  ┌──┐ ┌─────────────────────────┐                  │   │
│  │  │40│ │ Track Name  •  Artist   │   3:45           │   │
│  │  └──┘ └─────────────────────────┘                  │   │
│  │  [list of top 5 song results]                      │   │
│  │                                                    │   │
│  │  Albums / Artists / Playlists (horizontal strips)  │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
├────────────────────────────────────────────────────────┤
│  [Mini Player]                                          │
│  [Bottom Nav]                                           │
└────────────────────────────────────────────────────────┘

Search bar: auto-focus on navigation. Large variant before typing.
Results appear in real-time (debounced 300ms).
Categories hidden when results visible.
```

---

####   Player Screen (Full)

```
┌────────────────────────────────────────────────────────┐
│  [Transparent AppBar — just back button + queue icon]   │
│                                                          │
│                                                          │
│                                                          │
│              ┌────────────────────────┐                  │
│              │                        │                  │
│              │   Album Art 280dp       │                  │
│              │   20dp radius           │                  │
│              │   Shadow + glow         │                  │
│              │                        │                  │
│              └────────────────────────┘                  │
│                                                          │
│                    "Track Name"                           │
│                    headlineSmall, white                   │
│                                                          │
│                    "Artist Name"                          │
│                    bodyLarge, textSecondary               │
│                                                          │
│              ┌────────────────────────┐                  │
│              │  ────────●────────    │                  │
│              │  1:23          3:45    │                  │
│              └────────────────────────┘                  │
│                                                          │
│        ⤮      ⏮     ▶⏸     ⏭      🔁                  │
│        shuf   prev  play   next   repeat                 │
│                                                          │
│              ┌────────────────────────┐                  │
│              │  🔊 ────────●────     │                  │
│              └────────────────────────┘                  │
│                                                          │
│                 ♡     💬     ↻                            │
│              like  lyrics  queue                         │
│                                                          │
│                                                          │
└────────────────────────────────────────────────────────┘

Background: album art (blurred 40px, dark overlay 60%)
Album art: 280dp, 20dp radius, centered
Shadow around art: 60px primary glow
Volume slider: thinner (3px), thumb hides when not interacting
Like: heart icon, fills with rose gradient on active
Lyrics button: opens karaoke-style scrolling lyrics overlay
```

---

####   Album Detail Screen

```
┌────────────────────────────────────────────────────────┐
│  [Glass AppBar — transparent, appears on scroll]        │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │                                                    │   │
│  │    ┌──────────────┐                               │   │
│  │    │  Album Art   │     "Album Title"              │   │
│  │    │  200dp sq    │     Artist Name                │   │
│  │    │  16dp radius │     2024 • 12 songs • 45min    │   │
│  │    └──────────────┘                               │   │
│  │                                                    │   │
│  │    [Play] [Shuffle] [Download] [Heart] [More]      │   │
│  │                                                    │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  #1     Track 1                  3:45    ▸       │   │
│  ├──────────────────────────────────────────────────┤   │
│  │  #2     Track 2                  3:22    ▸       │   │
│  ├──────────────────────────────────────────────────┤   │
│  │  ... (track list)                                 │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  More Like This (horizontal scroll of album cards)       │
│                                                          │
├────────────────────────────────────────────────────────┤
│  [Mini Player]                                          │
│  [Bottom Nav — hidden on scroll]                        │
└────────────────────────────────────────────────────────┘

Header: album art floats above track list
Art position: 24dp from top, tilts slightly (3° rotation) on scroll parallax
Play button: PrimaryButton "Play" + PremiumIconButton "Shuffle" in row
Track list: 56dp height, numbered, right-aligned time
Active track: primary color number + text highlight
```

---

####   Artist Detail Screen

```
┌────────────────────────────────────────────────────────┐
│  [Glass AppBar — transparent]                           │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │            ⭕ (160dp circle)                      │   │
│  │         Artist Name (headlineLarge)                │   │
│  │         N monthly listeners (bodyMedium)           │   │
│  │                                                    │   │
│  │     [Follow]  [Play]  [Shuffle]  [More]            │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Popular    → See All                             │   │
│  │                                                    │   │
│  │  #1  Track 1                      45,678,901 ▶    │   │
│  │  #2  Track 2                      34,567,890 ▶    │   │
│  │  #3  Track 3                      23,456,789 ▶    │   │
│  │  #4  Track 4                      12,345,678 ▶    │   │
│  │  #5  Track 5                      11,234,567 ▶    │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Albums    → See All                              │   │
│  │  [horizontal scroll of album cards]               │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Fans Also Like    → See All                      │   │
│  │  [horizontal scroll of artist cards]              │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
├────────────────────────────────────────────────────────┤
│  [Mini Player]                                          │
└────────────────────────────────────────────────────────┘

Header: gradient background at top (based on artist's primary color)
Profile pic: 160dp circle, 2dp white border
Follow: SecondaryButton (glass), toggles to "Following" with primary tint
Popular tracks: numbered list with stream count (human-readable)
Albums + Related: horizontal scroll rows
```

---

####   Settings Screen

```
┌────────────────────────────────────────────────────────┐
│  [Glass AppBar]                                         │
│  "Settings"          [done]                             │
│  headlineLarge                                          │
├────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  ⭕ 64dp                                            │   │
│  │  Display Name                       Account ▸      │   │
│  │  user@email.com                                    │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Playback                                         │   │
│  ├──────────────────────────────────────────────────┤   │
│  │  Audio Quality                     Lossless ▸    │   │
│  │  Download Quality                  High ▸        │   │
│  │  Equalizer                         Custom ▸      │   │
│  │  Crossfade                         3s ▸          │   │
│  │  Gapless Playback              🔘                │   │
│  │  Volume Normalization          🔘                │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Appearance                                       │   │
│  ├──────────────────────────────────────────────────┤   │
│  │  Theme                         Dark ▸           │   │
│  │  Dynamic Color                 🔘                │   │
│  │  Reduce Motion                 🔘                │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Storage & Data                                   │   │
│  ├──────────────────────────────────────────────────┤   │
│  │  Storage Used                 2.4 GB             │   │
│  │  Downloaded Tracks             342                │   │
│  │  Clear Cache                   1.2 GB ▸          │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  About                                            │   │
│  ├──────────────────────────────────────────────────┤   │
│  │  Version                         2.4.0+345       │   │
│  │  Licenses                                         │   │
│  │  Terms of Service                                 │   │
│  │  Privacy Policy                                   │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
├────────────────────────────────────────────────────────┤
│  [Mini Player]                                          │
└────────────────────────────────────────────────────────┘

Sections: 12dp radius glass cards, 16dp internal padding
Tiles: 52dp height, with trailing icon (chevron or toggle)
Toggles: premium switch (glass track, primary gradient thumb)
Icons: 20dp, textTertiary, leading position
```

---

##  Responsive Breakpoints

```dart
enum Breakpoint {
  phone,    // < 600dp
  tablet,   // 600 - 840dp
  desktop,  // > 840dp
}

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.phone,
    this.tablet,
    this.desktop,
  });

  final Widget Function(BuildContext) phone;
  final Widget Function(BuildContext)? tablet;
  final Widget Function(BuildContext)? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 840 && desktop != null) {
          return desktop!(context);
        }
        if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!(context);
        }
        return phone(context);
      },
    );
  }
}
```

| Element | Phone (<600) | Tablet (600-840) | Desktop (>840) |
|---------|-------------|-------------------|----------------|
| Grid columns | 2 | 3 | 5 |
| Album art size | 140dp | 180dp | 220dp |
| Page padding | 16dp | 24dp | 32dp |
| Bottom nav | 5 items visible | 5 items + labels | Hidden (sidebar) |
| Mini player | Full width | Full width | 640dp max, centered |
| Search bar | Full width | 480dp, centered | 480dp, centered |
| Player art | 280dp | 360dp | 400dp |
| Content max width | 100% | 100% | 1024dp |

---

##  Premium Visual Details

### Detail 1: The Gradient Pulse

On the player screen, the album art glow subtly pulses (3-second cycle,
10% intensity variation). This mimics the "breathing" of audio equipment
and adds life to a static screen.

```dart
AnimatedContainer(
  duration: Duration(seconds: 3),
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: primary.withOpacity(0.2 + 0.1 * sin(time * 2 * pi / 3)),
        blurRadius: 60,
        spreadRadius: 10,
      ),
    ],
  ),
);
```

### Detail 2: The Nav Bar Lift

When the keyboard appears, the bottom nav bar smoothly slides down
(not jumps) — preventing the "keyboard push" that plagues most apps.

### Detail 3: Card Stacking

On the home screen, cards have a subtle offset shadow behind them,
creating a stacked card effect. Each card feels like a physical object.

### Detail 4: The Glass Reflection

Glass elements have a subtle diagonal gradient (top-left white, bottom-right
transparent) that mimics light hitting glass at an angle.

```dart
// Subtle diagonal shine on glass elements
ShaderMask(
  shaderCallback: (bounds) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.05),
      Colors.transparent,
    ],
  ).createShader(bounds),
  blendMode: BlendMode.overlay,
  child: child,
);
```

### Detail 5: The Play Button Ripple

When pressing play on an album card, a ripple emanates from the play button
to the card edges. The track starts with a slight delay (200ms) matching the
ripple animation — creating a cause-and-effect that feels physical.

---

##  Implementation Files

All design tokens are implemented in `lib/core/theme/`:

| File | Contents |
|------|----------|
| `color_schemes.dart` | Dark + Light ColorScheme, custom colors, gradients |
| `text_styles.dart` | All TextStyle definitions (Outfit + Inter) |
| `spacing.dart` | Spacing tokens |
| `durations.dart` | Animation duration constants |
| `shadows.dart` | All shadow definitions |
| `radius.dart` | Corner radius tokens |
| `app_theme.dart` | `ThemeData` factory for dark + light |
| `tokens.dart` | Aggregated design tokens class |

Premium widgets in `lib/shared/widgets/`:

| File | Widget |
|------|--------|
| `glass_widget.dart` | `GlassWidget` — reusable glassmorphism container |
| `premium_button.dart` | `PrimaryButton`, `SecondaryButton`, `PremiumIconButton` |
| `premium_bottom_nav.dart` | `PremiumBottomNav` — 72dp glass nav bar |
| `premium_app_bar.dart` | `PremiumAppBar` — scroll-aware glass app bar |
| `premium_search_bar.dart` | `PremiumSearchBar` — 52dp glass search |
| `album_card.dart` | `AlbumCard` — premium square album card |
| `artist_card.dart` | `ArtistCard` — premium circular artist card |
| `playlist_card.dart` | `PlaylistCard` — premium playlist card with overlay |
| `premium_dialog.dart` | `PremiumDialog` — glass dialog |
| `premium_snackbar.dart` | `PremiumSnackbar` — top-positioned glass snackbar |
| `shimmer_loading.dart` | `ShimmerLoading` — premium skeleton loader |
| `empty_state.dart` | `EmptyState` — premium empty state illustration |
| `error_state.dart` | `ErrorState` — premium error state with retry |
| `responsive_builder.dart` | `ResponsiveBuilder` — breakpoint-aware layout |
| `section_header.dart` | `SectionHeader` — "Title → See All" pattern |
| `track_list_tile.dart` | `TrackListTile` — premium track row |
