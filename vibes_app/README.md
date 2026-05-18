# Vibes App

A Flutter application for daily brain-state check-ins through voice analysis. Your voice reveals your brain's state — Vibes gives you sound to shift it.

---

## Table of Contents

- [Overview](#overview)
- [Screens](#screens)
- [Project Structure](#project-structure)
- [Design System](#design-system)
- [Assets](#assets)
- [Getting Started](#getting-started)
- [Dependencies](#dependencies)
- [Platform Support](#platform-support)
- [Changelog](#changelog)

---

## Overview

Vibes is an onboarding-first mobile app that guides users through a daily "vibe check" — a short spoken exercise where voice vibrations (not words) are analyzed to measure and shift brain readiness and frequency.

**Core concept:** Think of it like morning pages, but spoken. Every day your voice reveals your brain's state. Vibes gives you sound to shift it.

---

## Screens

### 1. Splash Screen (`features/splash/splash_screen.dart`)
- Displays `spalsh.png` centered on a `#15171B` background
- Scale + fade-in animation (0.7 → 1.0 scale over 900ms)
- Fade-out exit transition into the onboarding flow
- Total duration: ~2400ms before auto-navigating forward
- Native splash (iOS + Android) generated via `flutter_native_splash`

### 2. Vibe Check Screen — Onboarding Step 1 (`features/onboarding/screens/vibe_check_screen.dart`)
- **Top section (scrollable):** App icon badge (top right), welcome heading, and daily explanation copy
- **Bottom panel (fixed):** Privacy badge, "Catching Your Vibe" title, dual animated knob widgets, TALK button, page indicator dots, and close button
- Entry animation: fade + 6% upward slide on screen load
- Responsive: knob size scales with screen width (`38% of width`, clamped `130–190px`)
- Status bar: transparent, light icons

> Screens 2–4 (remaining onboarding steps) to be added in future iterations.

---

## Project Structure

```
vibes_app/
├── assets/
│   └── images/
│       ├── app_icon_1.png       # App logo used in top-right badge
│       ├── recoder_icon.png     # Center icon inside knob widgets
│       └── spalsh.png           # Splash screen image
│
├── lib/
│   ├── main.dart                # Entry point — portrait lock, status bar config
│   ├── app.dart                 # MaterialApp, dark theme, route to SplashScreen
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart        # All colors and gradients from Figma
│   │   │   ├── app_text_styles.dart   # Space Mono typography scale
│   │   │   └── app_assets.dart        # Centralized asset path constants
│   │   └── widgets/
│   │       ├── gradient_text.dart         # ShaderMask gradient text widget
│   │       └── gradient_icon_button.dart  # Gradient circle button widget
│   │
│   └── features/
│       ├── splash/
│       │   └── splash_screen.dart         # Animated splash → onboarding transition
│       └── onboarding/
│           ├── screens/
│           │   └── vibe_check_screen.dart # Onboarding screen 1
│           └── widgets/
│               ├── knob_widget.dart                # Animated vinyl turntable (CustomPainter)
│               ├── privacy_badge.dart              # Lock + privacy copy badge
│               ├── talk_button.dart                # Pulsing TALK button with waveform icon
│               └── onboarding_page_indicator.dart  # Animated gradient dot indicator
│
├── pubspec.yaml
└── README.md
```

---

## Design System

### Colors (`core/constants/app_colors.dart`)

| Token | Hex | Usage |
|---|---|---|
| `background` | `#15171B` | App-wide background |
| `surfacePanel` | `#0D0F12` | Bottom control panel |
| `surfaceDark` | `#141414` | Knob dark surfaces |
| `textPrimary` | `#FFFFFF` | Headings, bold labels |
| `textSecondary` | `#8E8E93` | Subtitles, captions |
| `textMuted` | `#48484A` | Placeholder, disabled |
| `accentCyan` | `#04EFF5` | Active indicator, TALK icon |
| `accentGreen` | `#11E560` | Accent gradient end |
| `accentGreen2` | `#2FE17A` | Secondary gradient start |
| `accentCyan2` | `#00FFF7` | Secondary gradient end |
| `knobOuter` | `#3A3A3C` | Knob ring, borders |
| `knobMid` | `#48484A` | Knob tick marks |
| `knobCenter` | `#2C2C2E` | Knob label area, button backgrounds |
| `indicatorInactive` | `#3A3A3C` | Inactive page dots |

**Gradients:**
- `accentGradient`: `#04EFF5 → #11E560` (left to right) — active indicator, highlights
- `accentGradient2`: `#2FE17A → #00FFF7` (top-left to bottom-right) — secondary accent
- `panelGradient`: `#666666 15% → #141414` (top to bottom) — panel overlays
- `knobShimmer`: `#1D1D1D → #000000` — knob base shading

### Typography (`core/constants/app_text_styles.dart`)

Font: **Space Mono** (Google Fonts — monospace, terminal aesthetic)

> Will be updated to match final Figma font specs in a future iteration.

| Style | Size | Weight | Usage |
|---|---|---|---|
| `displayLarge` | 24px | Regular | Welcome heading |
| `displayMedium` | 22px | Regular | Body onboarding text |
| `headingBold` | 18px | Bold | Panel title ("Catching Your Vibe") |
| `bodyMono` | 14px | Regular | Subtitles, secondary copy |
| `caption` | 10px | Regular | Privacy badge text |
| `labelSmall` | 11px | Bold | Small labels |
| `talkLabel` | 11px | Bold | TALK button label (cyan) |

---

## Assets

| File | Location | Used In |
|---|---|---|
| `spalsh.png` | `assets/images/` | Splash screen (native + Flutter) |
| `app_icon_1.png` | `assets/images/` | Top-right badge on vibe check screen |
| `recoder_icon.png` | `assets/images/` | Center of both knob widgets |

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.9.2`
- Dart SDK `^3.9.2`
- Xcode (for iOS)
- Android Studio / Android SDK (for Android)

### Install dependencies

```bash
flutter pub get
```

### Generate native splash screens

```bash
dart run flutter_native_splash:create
```

> Re-run this command whenever `spalsh.png` or the splash config in `pubspec.yaml` changes.

### Run the app

```bash
# iOS simulator
flutter run -d ios

# Android emulator
flutter run -d android

# List available devices
flutter devices
```

### Analyze code

```bash
flutter analyze lib/
```

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `google_fonts` | `^6.2.1` | Space Mono font |
| `cupertino_icons` | `^1.0.8` | iOS-style icons |
| `flutter_native_splash` | `^2.4.3` | Native splash screen (iOS + Android) |

---

## Platform Support

| Platform | Status |
|---|---|
| iOS | Supported |
| Android | Supported |
| Web | Not targeted |
| macOS | Not targeted |

- Portrait mode locked (both portrait orientations)
- Transparent status bar with light icons
- Safe area padding respected on all devices (notch, Dynamic Island, chin)
- Knob widget size is responsive to screen width

---

## Changelog

### v1.0.0 — Initial Build
- Project scaffold with feature-based folder structure
- `AppColors`, `AppTextStyles`, `AppAssets` constants defined from Figma
- Native splash screen (iOS + Android) using `spalsh.png` on `#15171B`
- Animated Flutter splash screen with scale + fade transition
- Onboarding Screen 1 — "Catching Your Vibe" (vibe check screen)
  - Scrollable text content area with fade + slide entry animation
  - Dual animated vinyl knob widgets (rotating tick marks, `CustomPainter`)
  - Privacy badge, pulsing TALK button, page indicator dots, close button
  - Responsive layout for all screen sizes
- Dark theme applied app-wide via `app.dart`
- Portrait orientation locked in `main.dart`
- `displayLarge` font size adjusted to 24px (down from 28px) for better layout fit
