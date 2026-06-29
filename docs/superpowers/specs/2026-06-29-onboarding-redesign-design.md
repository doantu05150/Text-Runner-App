# Onboarding Redesign — Design

**Date:** 2026-06-29
**Status:** Approved (pending spec review)

## Problem

The first-run onboarding (`lib/screens/onboarding_screen.dart`) is visually plain:
each of the 3 pages is a single centered Material icon (96px), a title, a
paragraph, a button, and a native ad. There is no color variety, no
illustration, and all three pages look identical apart from the icon and text.

## Goal

Make onboarding feel richer and more colorful — add real illustrations and give
each page its own visual identity — **without** changing the existing flow,
copy, routing, or ad behavior.

## Non-goals

- No changes to the 3-page structure, route names, or navigation.
- No changes to the native-ad gating logic (delay / timeout / min-visible /
  enable-button). It is preserved exactly.
- No new copy and no localization work — existing English strings are kept.
- No external image/Lottie assets; no new packages.

## Chosen direction

**Direction B — bright gradient + playful flat illustration** (selected by user).

- Light, vibrant look with a bold gradient "hero" panel at the top of each page.
- A friendly **flat vector illustration** sits in the hero.
- Each page has its own accent color so the flow feels varied:
  - **Page 1 "Easy to use"** — Coral → Pink (`#FF8A4C` → `#FF5E7E`)
  - **Page 2 "Make it yours"** — Purple → Magenta (`#9B5CFF` → `#FF6FD8`)
  - **Page 3 "Save your favorites"** — Teal → Green (`#13C2C2` → `#3BD17A`)

The onboarding uses its **own fixed bright palette**, independent of the app's
dark/light theme (`AppColors`). Rationale: onboarding runs on first launch
before the user has chosen a theme, and Direction B is inherently bright. Button
foreground text is white; page background is `#FFFFFF`; body text uses dark
neutrals (`#23202B` title, `#5C5866` description).

## Layout (portrait)

The app is portrait-locked (`main.dart:32`, `DeviceOrientation.portraitUp`).
Top-to-bottom on each page:

```
┌─────────────────────────────┐
│   HERO  (≈46% height)        │  gradient + illustration, full-bleed,
│        [illustration]        │  rounded bottom corners
├─────────────────────────────┤
│   Title (bold, ~22)          │  centered
│   Description (~14, muted)   │  centered, max ~3 lines
│                              │
│   ● ● ●  page dots           │  active dot uses page accent color
│   [   Next / Start   ]       │  pill button, page accent fill
├─────────────────────────────┤
│   NATIVE AD (pinned bottom)  │  unchanged slot, _adSlotHeight
└─────────────────────────────┘
```

- Page-indicator **dots** (3) below the description; the active dot is elongated
  and uses the page's accent color.
- The **button** becomes a full-width pill filled with the page accent color
  (replaces the current right-aligned `ElevatedButton`). Label unchanged
  ("Next" / "Start").
- The **native ad** stays pinned at the bottom in the same slot, with the same
  load/gating behavior.
- **No "Skip" link** — this preserves the current forced progression through the
  ad gate. (Flagged as an easy future add-on if desired; called out here so it
  can be reconsidered at spec review.)

## Entrance animation

When each page mounts, the illustration and text animate in with a short
fade + slight upward slide (e.g. `AnimatedOpacity` / `TweenAnimationBuilder`,
~400ms, illustration leading text slightly). Lightweight, no new package. Adds
life and reinforces "more varied".

## Illustrations (code-drawn flat vector)

Each illustration is a Flutter widget drawn with `CustomPaint` (shapes,
gradients, soft shadow) — no asset files. Each is a self-contained, reusable
widget that takes its accent colors as parameters and paints on a transparent
background (the hero gradient shows behind it).

- **Page 1 — `OnboardingArtEasy`**: a stylized phone showing glowing scrolling
  letters, with a small play/tap burst.
- **Page 2 — `OnboardingArtCustomize`**: a paint palette / color swatches with a
  slider, suggesting customization.
- **Page 3 — `OnboardingArtSave`**: a starred bookmark card (saved chips).

These live in a new file `lib/screens/onboarding_art.dart` so each painter is
small and the page file stays focused.

## Component structure

Refactor `_OnboardingScaffold` to drive the new layout, keeping all existing ad
state/timer logic untouched. New per-page inputs:

- `gradientColors` (List<Color>) — hero gradient.
- `accent` (Color) — dots + button fill.
- `illustration` (Widget) — the page's `CustomPaint` art.
- `pageIndex` (int, 0–2) — which dot is active.

`OnboardingPage1/2/3` keep their current responsibilities (titles, descriptions,
cache keys, `onNext` callbacks, first-launch flag write) and simply pass the new
visual parameters down. Route wiring in `main.dart` is unchanged.

A small private palette/const block at the top of the file holds the three
gradient/accent triples so they're defined in one place.

## Files affected

- `lib/screens/onboarding_screen.dart` — rewrite the scaffold layout (hero +
  body + dots + pill button + pinned ad); add per-page visual params; keep ad
  logic and page classes' existing behavior.
- `lib/screens/onboarding_art.dart` — **new**: three `CustomPaint`
  illustration widgets + their painters.

Not touched: `main.dart` routes, `app_theme.dart`, ad infrastructure, copy.

## Testing / verification

- `flutter analyze` clean.
- Manual run: walk the 3 onboarding pages on first launch; verify per-page
  colors, illustrations render, dots advance, entrance animation plays, the
  button still gates on the ad exactly as before, and "Start" writes the
  first-launch flag and lands on `/`.
- Sanity-check the layout doesn't overflow with the ad present on a typical
  portrait phone.
