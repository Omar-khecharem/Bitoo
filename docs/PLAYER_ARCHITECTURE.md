# BITOO Music Player — World-Class Design

> The player is the soul of BITOO. Every pixel breathes with the music.

---

##  Design Principles

| Principle | Manifestation |
|-----------|---------------|
| **Music-First** | The album art is the hero. Everything else is glass floating over it. |
| **Physicality** | Buttons depress, vinyl spins, cards stack — digital objects obey physics. |
| **Alive** | The UI breathes, pulses, and moves in sync with the audio stream. |
| **Fluid** | Zero hard cuts. Every state change is a transition. |
| **Subservient** | Controls fade when not needed. The music is always center stage. |

---

##  Component Hierarchy

```
FullscreenPlayerPage
├── PlayerBackground              (blurred album art + animated gradient overlay)
├── GestureHandler                 (swipe, tap, pinch, long-press detection)
├── AlbumArtSection                (top 45% of screen)
│   ├── AlbumArtView               (static mode — hero image)
│   ├── RotatingVinyl              (vinyl mode — spinning disk)
│   ├── WaveAnimation              (visualizer mode — reactive bars)
│   └── AlbumArtBreathe            (subtle scale pulse in sync with BPM)
├── TrackInfoSection               (track name + artist + metadata)
│   ├── TrackTitle                 (marquee scroll on overflow)
│   ├── ArtistName                 (tappable → artist page)
│   └── LikeButton                 (heart icon with bounce animation)
├── ProgressSection
│   ├── SeekBar                    (custom slider with waveform preview)
│   ├── CurrentTimeLabel
│   └── DurationLabel
├── ControlsSection
│   ├── ShuffleButton              (toggle, color pop)
│   ├── PreviousButton             (tap: restart, double-tap: prev track)
│   ├── PlayPauseButton            (56dp, morphing icon)
│   ├── NextButton                 (tap: next, long-press: fast-forward)
│   └── RepeatButton               (cycle: none → one → all → none)
├── ExtrasSection
│   ├── VolumeSlider               (thin, hides on idle)
│   ├── LyricsToggle               (opens floating lyrics overlay)
│   ├── QueueToggle                (opens queue bottom sheet)
│   ├── EqualizerToggle            (opens effects panel)
│   └── SleepTimerIndicator        (pill showing remaining time)
├── FloatingLyricsOverlay          (full-screen karaoke)
│   ├── LiveLyricsLine             (current line, large, glowing)
│   ├── PastLyricsLine             (faded, scrolled up)
│   └── FutureLyricsLine           (dimmed, scrolled down)
├── QueueSheet (BottomSheet)
│   ├── QueueHeader                (title + clear button)
│   ├── QueueList                  (reorderable, swipe-to-delete)
│   │   └── QueueItem              (drag handle, art, title, subtitle, delete)
│   └── SuggestedTracks            (horizontal scroll of recommendations)
├── AudioEffectsPanel (BottomSheet)
│   ├── EqualizerWidget            (10-band sliders)
│   ├── BassControl                (slide: -12dB to +12dB)
│   ├── VirtualizerControl         (slide: 0-100%)
│   ├── PresetsDropdown            (pop, rock, jazz, classical, custom)
│   ├── CrossfadeControl           (slide: 0-12 seconds)
│   ├── FadeControl                (fade in/out toggles + duration)
│   └── ResetButton
└── SleepTimerSheet (BottomSheet)
    ├── PresetDurations            (5, 10, 15, 30, 45, 60 min)
    ├── CustomDuration             (number picker)
    ├── EndOfTrack                 (option: stop at end of current track)
    └── ActiveTimerDisplay         (circular countdown when active)
```

---

##  Animation System — Complete Reference

### 1. Album Art Animations

#### 1A. Hero Transition (Page Entry)

```
Trigger:    Navigate to player from album/playlist card
Duration:   500ms
Curve:      easeInOutCubic
Elements:
  - Album art scales from card position/size to full player position
  - Background album art fades in (0 → 1 opacity, blur 0 → 40)
  - Controls fade in staggered: 0ms → progress, 100ms → controls, 200ms → extras
  - Card clipping (12dp radius) morphs to no radius

Implementation:
  Hero(tag: 'album_art_${trackId}',
    flightShuttleBuilder: (ctx, anim, dir, fromCtx, toCtx) {
      return ClipRRect(
        borderRadius: BorderRadius.lerp(
          Radius.circular(12), Radius.circular(0), anim.value,
        ),
        child: albumArtWidget,
      );
    },
  );
```

#### 1B. Rotating Vinyl Mode

```
Trigger:    User taps album art OR toggles vinyl mode
Duration:   Continuous (2s per revolution = 33.3 RPM)
Animation:  360° rotation on Z axis
Curve:      Linear (continuous) + easeOut on start/stop

Implementation:
  final rotationController = AnimationController(
    vsync: this,
    duration: Duration(seconds: 2),
  )..repeat();

  Transform.rotate(
    angle: rotationController.value * 2 * pi,
    child: CustomPaint(
      painter: VinylPainter(),  // Draws grooves + reflections
      child: ClipRRect(
        borderRadius: BorderRadius.circular(albumArtSize / 2),
        child: Image.network(albumArtUrl, fit: BoxFit.cover),
      ),
    ),
  );

Vinyl Details:
  - Outer ring: 4dp, black (#1A1A1A)
  - Grooves: concentric circles with decreasing opacity (1% → 5% → 1%)
  - Light reflection: diagonal gradient sweep that rotates at 2x speed
  - Center label: 60dp white circle with track info text
  - Tonearm: painted element, appears from right on vinyl start

Why vinyl? Vinyl is the universal symbol of music listening. The rotation
creates a hypnotic focal point that makes the player feel alive even when
the user is not actively interacting.
```

#### 1C. Heartbeat Pulse (Breathe)

```
Trigger:    Always active when music is playing
Duration:   Synchronized to track BPM (or 70 BPM default = 857ms cycle)
Animation:  Scale 1.0 → 1.03 → 1.0
Curve:      Sine wave (smooth in-out)

Implementation:
  Transform.scale(
    scale: 1.0 + 0.03 * (0.5 + 0.5 * sin(time * 2 * pi / beatDuration)),
    child: AlbumArtWidget(),
  );

Why breathe? Living things breathe. By adding a micro pulse synchronized
to the music's BPM, the player subconsciously communicates "I am alive
and I feel the music."
```

#### 1D. Audio-Reactive Glow

```
Trigger:    Active during loud passages (above volume threshold)
Duration:   Real-time (60fps via audio analysis)
Animation:  Shadow glow intensity scales with audio amplitude
            hue shifts slightly based on frequency content

Implementation:
  AnimatedContainer(
    duration: Duration(milliseconds: 50),  // Near-instant response
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.2 + amplitude * 0.3),
          blurRadius: 40 + amplitude * 40,
          spreadRadius: 5 + amplitude * 15,
        ),
      ],
    ),
  );

Why audio-reactive? The album art glow becomes a visual equalizer.
Loud chorus = bright glow. Quiet verse = subtle glow. The music is
visible.
```

### 2. Wave Animation (Visualizer)

#### 2A. Linear Frequency Bars

```
Trigger:    User swipes up on album art OR toggles visualizer mode
Duration:   Continuous (60fps update)
Animation:  Bars rise and fall with frequency band amplitudes

Layout:
  ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
  │  │  │  │  │  │  │  │  │  │  │  │  │  16 bars
  └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
  [bass] ──────────────── [treble]

Implementation:
  CustomPaint(
    painter: WavePainter(
      amplitudes: currentAmplitudes,  // List<double> length 16
      color: primaryColor,
      barWidth: 8,
      barSpacing: 4,
      borderRadius: 4,  // Rounded tops
    ),
  );

  class WavePainter extends CustomPainter {
    @override
    void paint(Canvas canvas, Size size) {
      final barWidth = (size.width - spacing * (amplitudes.length - 1)) / amplitudes.length;
      for (var i = 0; i < amplitudes.length; i++) {
        final height = amplitudes[i] * size.height;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(i * (barWidth + spacing), size.height - height, barWidth, height),
          Radius.circular(borderRadius),
        );
        canvas.drawRRect(rect, Paint()..shader = primaryGradient.createShader(rect));
      }
    }
  }

Why bars? Frequency bars are the universal visualizer language. Rounded
tops → premium feel. Gradient fill → depth. Smooth interpolation between
frames → no jitter.
```

#### 2B. Circular Waveform

```
Trigger:    User taps visualizer to switch mode
Animation:  Circular wave radiates from album art center
            16 nodes on circle perimeter, connected by bezier curves

Implementation:
  CustomPaint(
    painter: CircularWavePainter(amplitudes),
  );

  // Nodes move in/out radially from center based on amplitude
  // Connected by smooth Catmull-Rom curves
  // Outer glow on each node

Why circular? A circular waveform wraps around the album art like
a halo. It visualizes the music "radiating" from the album art.
```

### 3. Floating Lyrics (Karaoke Mode)

```
Trigger:    Tap lyrics button OR swipe up on track info
Duration:   300ms sheet transition
Animation:  Sheet slides up from bottom, lyrics fade in staggered

Layout (full screen overlay):
  ┌──────────────────────────────────────┐
  │  ✕ (dismiss, top-right, glass icon)  │
  │                                       │
  │                                       │
  │    Past line (opacity 0.3, size 14)  │
  │    Past line (opacity 0.5, size 16)  │
  │                                       │
  │  ◆ CURRENT LINE (opacity 1.0, 24) ◆  │  ← Glowing, centered
  │  ◆ highlighted word sweeps ◆         │  ← Word-by-word highlight
  │                                       │
  │    Future line (opacity 0.4, 16)     │
  │    Future line (opacity 0.2, 14)     │
  │                                       │
  │                                       │
  │  ───── ✋ drag handle ─────           │
  └──────────────────────────────────────┘

Animations:
  - Word highlight sweep: gradient fill animates left → right
  - Line transition: current → past (scale 1→0.9, fade 1→0.3, scroll up)
  - Auto-scroll: smooth 300ms scroll to center current line
  - Tap on word: seek to that word's timestamp (with ripple feedback)

Why floating? Lyrics are an intimate, shared experience. Floating them
over the blurred album art creates a karaoke-bar atmosphere. The glowing
current line draws focus. Past/future lines provide context without
distraction.
```

### 4. Live Lyrics (Real-Time Sync)

```
Architecture:
  - LRC file format parsing (or API response with timestamped lines)
  - Each line has: {startMs, endMs, text, words: [{startMs, endMs, text}]}
  - Timer driven by audio position (100ms ticks)
  - Current line determined by: audioPosition >= line.startMs

Animation States:
  line {
    past:     opacity 0.4, y-offset -20, scale 0.95
    current:  opacity 1.0, y-offset 0, scale 1.0, text glow
    future:   opacity 0.3, y-offset 20, scale 0.95
  }

  word {
    not-yet-highlighted: color = textTertiary
    highlighted: color = primary (gradient sweep)
    done: color = textSecondary
  }

Implementation:
  LayoutBuilder → SingleChildScrollView with AutoScrollController
  Each line: AnimatedBuilder listening to player position stream
  Line transition: AnimatedPositioned + AnimatedOpacity

Why live? This is the definitive music player feature. Watching the
words highlight in real-time creates an emotional connection deeper
than any other UI element. It's the difference between listening and
experiencing.
```

### 5. Gesture Controls

```
┌──────────────────────────────────────────────────────┐
│  Gesture Map (on FullscreenPlayerPage)                │
│                                                       │
│  ┌────────────────────────────────────────────────┐  │
│  │  SINGLE TAP: Play/Pause                        │  │
│  │  └─ Ripple at tap location                      │  │
│  ├────────────────────────────────────────────────┤  │
│  │  DOUBLE TAP: Toggle Like (heart)               │  │
│  │  └─ Heart icon pops at tap location + bursts   │  │
│  ├────────────────────────────────────────────────┤  │
│  │  SWIPE LEFT: Next Track                        │  │
│  │  └─ Album art slides left, new slides in       │  │
│  ├────────────────────────────────────────────────┤  │
│  │  SWIPE RIGHT: Previous Track                   │  │
│  │  └─ Album art slides right, new slides in      │  │
│  ├────────────────────────────────────────────────┤  │
│  │  SWIPE UP: Open Queue                          │  │
│  │  └─ Queue sheet follows finger (drag)          │  │
│  ├────────────────────────────────────────────────┤  │
│  │  SWIPE DOWN: Close Player                      │  │
│  │  └─ Player shrinks to mini-player (hero reverse)│  │
│  ├────────────────────────────────────────────────┤  │
│  │  LONG PRESS on art: Toggle vinyl mode          │  │
│  │  └─ Art morphs to spinning vinyl (500ms)       │  │
│  ├────────────────────────────────────────────────┤  │
│  │  PINCH on art: Toggle visualizer mode          │  │
│  │  └─ Art shrinks, waves expand around it        │  │
│  └────────────────────────────────────────────────┘  │
│                                                       │
│  Gesture conflict resolution:                         │
│  - Tap vs Swipe: 10px threshold, 200ms timeout       │
│  - Single vs Double: 300ms gap window                │
│  - Vertical vs Horizontal: 12° angle threshold       │
│  - Long press: 500ms hold + no movement              │
└──────────────────────────────────────────────────────┘

Implementation:
  GestureDetector(
    onTap: _handleTap,
    onDoubleTap: _handleDoubleTap,
    onLongPress: _handleLongPress,
    onVerticalDragStart: _handleVerticalDragStart,
    onVerticalDragUpdate: _handleVerticalDragUpdate,
    onVerticalDragEnd: _handleVerticalDragEnd,
    onHorizontalDragStart: _handleHorizontalDragStart,
    onHorizontalDragUpdate: _handleHorizontalDragUpdate,
    onHorizontalDragEnd: _handleHorizontalDragEnd,
    onScaleStart: _handleScaleStart,     // Pinch
    onScaleUpdate: _handleScaleUpdate,
    onScaleEnd: _handleScaleEnd,
  );

Why gestures? Gestures are the most natural interface for a music player.
You don't click a "next" button — you flick the album art aside like
a physical record. This physicality is what separates BITOO from every
other player.
```

### 6. Swipe Queue

```
Trigger:    Swipe up globally OR tap queue icon
Behavior:   Queue sheet follows finger (not triggered at threshold)

Queue Item Layout:
  ┌──────────────────────────────────────────────┐
  │  ≡ (drag handle, 24dp)                       │
  │  40dp sq art │ Track Name           ✕ (3:45) │
  │              │ Artist Name                   │
  └──────────────────────────────────────────────┘

Animations:
  - Drag handle: item lifts (shadow elevates, scale 1.03)
  - Reorder: items slide apart (spring animation, 300ms)
  - Swipe-to-delete: item slides right, reveals red delete bg
  - New item added: slide in from bottom (200ms, easeOut)
  - Item removed: collapse + fade (200ms, easeIn)
  - Empty queue: "Queue is empty" state fades in (300ms)

Why swipe reorder? Music queues are dynamic. People want to rearrange
their listening order on the fly. Physical drag-and-drop is the most
satisfying way to do this.
```

### 7. Player State Transitions

```
Mini Player ──(tap)──► Fullscreen Player ──(swipe down)──► Mini Player
                              │
                    ┌─────────┼─────────┐
                    │         │         │
                    ▼         ▼         ▼
              Visualizer   Vinyl     Lyrics
                 Mode       Mode      Overlay

Each transition:
  - Tracks: Hero animation for album art
  - Duration: 400ms (standard), 500ms (hero)
  - Curve: easeInOutCubic
  - Stagger: art → info → controls → extras (50ms each)
```

### 8. Player Background

```
┌──────────────────────────────────────────────────────┐
│  Background Compositing Pipeline                      │
│                                                       │
│  1. Album art (full screen, scaled up 2x)            │
│  2. ImageFilter.blur(sigmaX: 40, sigmaY: 40)         │
│  3. ColorFiltered(ColorFilter.mode(                   │
│       BlendMode.srcOver, color: 0x80000000))          │
│  4. Animated gradient overlay (pulses subtly)         │
│       colors: [transparent, black 40%, black 60%]    │
│       begin: topCenter, end: bottomCenter             │
│  5. Optional: particle system (floating notes)        │
│                                                       │
│  All animations: 60fps via CustomPainter + Ticker    │
└──────────────────────────────────────────────────────┘
```

---

##  Feature Deep Dives

### Equalizer + Effects Panel

```
┌──────────────────────────────────────────────────────┐
│  Audio Effects                          [Reset] [✕]  │
├──────────────────────────────────────────────────────┤
│                                                       │
│  ┌─ Preset: Pop ▾ ──────────────────────────────┐    │
│  │  [Pop] [Rock] [Jazz] [Classical] [+ Custom]  │    │
│  └──────────────────────────────────────────────┘    │
│                                                       │
│  10-Band Equalizer                                    │
│  ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐                    │
│  │  │  │  │  │  │  │  │  │  │  │  0dB center line    │
│  └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘                    │
│  31  63  125 250 500 1k  2k  4k  8k  16k (Hz)        │
│                                                       │
│  ── Bass Boost ──────────────────────────────────     │
│  🔊 ───────●───────────────────────────── 🔊         │
│  -12dB                    0dB              +12dB      │
│                                                       │
│  ── Virtualizer (3D Audio) ──────────────────────     │
│  ○ ────────────●───────────────────────── ○          │
│  0%                        50%              100%      │
│                                                       │
│  ── Crossfade ───────────────────────────────────     │
│  [Off] ──────●────────────────────────── [12s]       │
│  0s                       6s                  12s     │
│                                                       │
│  ── Fade In ────────────────────────────────────     │
│  [✓] Duration: 3s ▾                                  │
│                                                       │
│  ── Fade Out ───────────────────────────────────     │
│  [✓] Duration: 5s ▾                                  │
│                                                       │
└──────────────────────────────────────────────────────┘

Equalizer animation: frequency response curve drawn as bezier
  path on canvas. Sliders snap at center (0dB) with haptic
  feedback. Preset change animates sliders to new positions
  (200ms stagger, left-to-right).
```

### Sleep Timer

```
┌──────────────────────────────────────────────────────┐
│  Sleep Timer                               [Cancel]  │
├──────────────────────────────────────────────────────┤
│                                                       │
│  ┌──────────────────────────────────────────────┐    │
│  │                                              │    │
│  │           ⏱  25:00 remaining                  │    │
│  │          (circular progress indicator)        │    │
│  │                                              │    │
│  └──────────────────────────────────────────────┘    │
│                                                       │
│  Quick:  [5m] [10m] [15m] [30m] [45m] [60m]         │
│                                                       │
│  Custom:  ┌──────┐  [Set]                            │
│           │ 25   │  minutes                           │
│           └──────┘                                   │
│                                                       │
│  ○ Stop after current track                           │
│  ○ Fade out over last 30 seconds                      │
│                                                       │
└──────────────────────────────────────────────────────┘

  Animation: circular countdown clock (sweep + number tick,
    60fps). When timer expires: volume fades over 3 seconds
    (linear 1.0 → 0.0), then playback pauses.
```

### Media Notification + Lock Screen

```
┌──────────────────────────────────────────────────────┐
│  Android Notification (expanded)                      │
│                                                       │
│  ┌──┬───────────────────────────────────────────┐    │
│  │40│  Track Name                    ┌────┐      │    │
│  │px│  Artist Name      Album Name   │ ▢  │      │    │
│  │sq│  ──────────────────────●─────  └────┘      │    │
│  │  │  ⏮   ▶⏸   ⏭   ♡                     │    │
│  └──┴───────────────────────────────────────────┘    │
│                                                       │
│  Android Lock Screen Controls:                       │
│  ┌──────────────────────────────────────────────┐    │
│  │  ⏮   ▶⏸   ⏭                              │    │
│  │  ── album art as background ──               │    │
│  └──────────────────────────────────────────────┘    │
│                                                       │
│  Bluetooth AVRCP:                                    │
│  - Track info: title, artist, album, duration         │
│  - Art: convert to byte array, send over AVRCP 1.6   │
│  - Controls: play/pause, next, prev, like            │
│  - Position: 1s updates                               │
└──────────────────────────────────────────────────────┘
```

### Landscape Mode

```
┌──────────────────────────────────────────────────────┐
│                                                        │
│  ┌──────────────┐   ┌──────────────────────────┐     │
│  │              │   │  Track Name        ♡     │     │
│  │  Album Art   │   │  Artist Name             │     │
│  │  40% width   │   │                          │     │
│  │  max 400dp   │   │  ────────●────           │     │
│  │              │   │  1:23          3:45       │     │
│  │              │   │                          │     │
│  │  [Vinyl] [V] │   │  ⤮  ⏮  ▶⏸  ⏭  🔁      │     │
│  │              │   │                          │     │
│  │              │   │  🔊 ────●────            │     │
│  └──────────────┘   │  [Lyrics] [Queue] [EQ]   │     │
│                      └──────────────────────────┘     │
│                                                        │
└──────────────────────────────────────────────────────┘

Layout: Album art on left (fixed), controls on right (scrollable)
Animations: same as portrait, adapted positions
Breakpoint: width > height = landscape
```

### Tablet Mode

```
┌────────────────────────────────────────────────────────┐
│                                                          │
│  ┌────────────────────┐  ┌──────────────────────────┐  │
│  │                     │  │                          │  │
│  │   Album Art 400dp   │  │  Track Name              │  │
│  │   + vinyl mode      │  │  Artist Name             │  │
│  │   + wave visualizer │  │                          │  │
│  │                     │  │  ──────●──────           │  │
│  │                     │  │  1:23          3:45      │  │
│  │                     │  │                          │  │
│  │                     │  │  ⤮  ⏮  ▶⏸  ⏭  🔁      │  │
│  │                     │  │                          │  │
│  │                     │  │  ─────── Lyrics ──────   │  │
│  │                     │  │  Past line text          │  │
│  │                     │  │  ◆ Current line ◆        │  │
│  │                     │  │  Future line text        │  │
│  └────────────────────┘  └──────────────────────────┘  │
│                                                          │
└────────────────────────────────────────────────────────┘

Tablet advantage: lyrics and player side-by-side. Album art on left
(vinyl + visualizer), player controls + lyrics on right. This is the
definitive BITOO experience.
```

---

##  UX Improvements Over Spotify

| Feature | Spotify | BITOO |
|---------|---------|-------|
| Album art | Static | Rotating vinyl / breathing / reactive glow |
| Player bg | Flat gradient | Blurred album art with animated overlay |
| Lyrics | Text only | Karaoke-style word highlighting, floating |
| Gestures | None | Swipe, pinch, long press, double tap |
| Queue | Fixed | Drag-to-reorder, swipe-to-delete |
| Equalizer | Basic 6-band | 10-band + bass + virtualizer + presets |
| Crossfade | Toggle only | 0-12s adjustable + fade in/out |
| Animations | Minimal | Spring physics, stagger, hero transitions |
| Tablet | Scaled phone | Split-pane: art + lyrics side by side |
| Vinyl mode | Not available | Full vinyl simulation with grooves |
| Wave visualizer | Not available | 3 modes: bars, circular, particle |

---

##  File Implementation Plan

All code lives in `lib/features/player/presentation/`:

| File | Responsibility |
|------|----------------|
| `fullscreen_player_page.dart` | Main player scaffold, layout, gesture handler |
| `landscape_player_page.dart` | Landscape orientation layout |
| `tablet_player_page.dart` | Tablet split-pane layout |
| `album_art_view.dart` | Album art with hero + breathe + glow |
| `rotating_vinyl.dart` | Vinyl simulation with CustomPainter |
| `wave_animation.dart` | 3 visualizer modes (CustomPainter) |
| `player_controls.dart` | All transport controls |
| `seek_bar.dart` | Custom slider with waveform thumb |
| `progress_labels.dart` | Time labels |
| `volume_slider.dart` | Thin glass volume slider |
| `lyrics_view.dart` | Floating lyrics overlay |
| `live_lyrics.dart` | Real-time word highlighting |
| `queue_sheet.dart` | Queue bottom sheet + reorder |
| `audio_effects_panel.dart` | EQ + bass + virtualizer + presets |
| `equalizer_widget.dart` | 10-band equalizer with CustomPainter |
| `sleep_timer_sheet.dart` | Sleep timer bottom sheet |
| `floating_player.dart` | Mini-player variant |
| `audio_notification.dart` | Notification + lock screen |

All domain logic in `lib/features/player/domain/`:

| File | Entity |
|------|--------|
| `track.dart` | `TrackEntity` — id, title, artist, duration, etc. |
| `queue.dart` | `QueueEntity` — ordered track list |
| `playback_state.dart` | `PlaybackState` — idle/playing/paused/buffering |
| `repeat_mode.dart` | `RepeatMode` — none/one/all |
| `equalizer_preset.dart` | `EqualizerPreset` — name + band levels |
| `crossfade_settings.dart` | `CrossfadeSettings` — duration + enabled |
| `sleep_timer.dart` | `SleepTimer` — duration + remaining + active |

All providers in `lib/features/player/presentation/providers/`:

| Provider | State |
|----------|-------|
| `player_state_provider.dart` | PlaybackState, current track, position |
| `queue_provider.dart` | Queue of tracks |
| `equalizer_provider.dart` | EQ bands + active preset |
| `audio_effects_provider.dart` | Bass, virtualizer, crossfade, fade |
| `sleep_timer_provider.dart` | Timer state |
| `volume_provider.dart` | Volume level |
