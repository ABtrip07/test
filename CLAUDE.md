# CLAUDE.md - heybud

## Product
heybud is a mobile-first routing app for cannabis users. Enter a destination,
get dispensaries and munchie stops along the route, ranked by detour cost
(minutes added) rather than raw distance.

Tagline: Dispensaries and munchies, on the way.
Domain: heybudhq.com

## Stack
- Expo (React Native) + TypeScript
- Google Maps SDK: Directions + Places autocomplete
- Dispensary data: Weedmaps API (primary), Leafly (fallback)
- Munchie data: Google Places filtered to a curated category whitelist
- State: lightweight (Zustand or React Context) — no global Redux

## Architecture
- `src/screens/` — one screen per file (AgeGate, Home, Results)
- `src/components/` — reusable presentational components
- `src/theme/` — colors, typography, spacing tokens. No inline magic numbers.
- `src/routing/` — pure functions for detour math and stop insertion
- `src/services/` — API clients (places, directions, dispensaries, munchies).
  Stubs by default; wire real keys via `.env`.
- `src/state/` — app-level state (destination, toggles, results)
- `src/types/` — shared TypeScript types

## Routing algorithm (the differentiator)
1. Compute baseline direct route: origin → destination
2. Pre-filter candidates by route-corridor bounding box
3. For each candidate, detour cost = (origin → stop → destination) − baseline
4. For dispensary + munchies combo: dispensary inserted before munchies
   (user wants munchies near destination, not before pickup)
5. Cap candidates at ~10 per category before insertion math; cache aggressively

## Design system
- Premium, restrained, dark-first. Think Linear / Arc / Things 3.
- Background: near-black (`#0A0A0A` family)
- Accent: warm amber. Never green.
- Typography: Inter. Single family, weight does the work.
- Wordmark: lowercase `heybud`, no caps in UI.
- Animations: spring physics, slow. Premium feels unhurried.
- Haptics on iOS for selections and route updates.

## Voice
Conversational, dry, confident. Never winks. No weed puns or emoji-as-personality.
Vocabulary: "dispensary" and "munchies" — own those words.

## Compliance
- 21+ age gate before any cannabis content
- Apple App Store has historically rejected cannabis apps — research current
  policy before submitting. May need web app + sideload route initially.
- Geofence dispensary results to legal states
- Display + handoff only. Do not facilitate purchase in-app.

## Out of scope for v0
Accounts, favorites, history, pre-order, push, deals, reviews, social,
multi-stop beyond dispensary + munchies.

## Coding standards
- TypeScript strict mode
- One component per file; filename matches export
- Functional components with hooks; no class components
- No default exports for components — named exports for greppability
- Theme tokens for all colors/spacing/typography; no inline hex or magic numbers
- Service layer returns typed data; UI never talks to APIs directly
- Comments only when the WHY is non-obvious
