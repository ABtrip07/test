# CLAUDE.md - heybud

## Product
heybud is a mobile + web routing app for impaired users — cannabis or alcohol —
who need to get somewhere safely and want stops on the way. Enter a destination
(or tap a saved friend / spot), get dispensaries and munchie stops along the
route, ranked by detour cost (minutes added) rather than raw distance.

Tagline: Dispensaries and munchies, on the way.
Domain: heybudhq.com (web is the primary launch surface — App Store gates
cannabis apps; native iOS/Android follow once policy risk is cleared).

## Audience
heybud serves the broader "altered-state navigator" market, not just cannabis:
- **Cannabis users** going to a friend's place / party / outdoor spot
- **Late-night walkers** — bar-goers walking home at midnight, drunk-munchies
  pickup en route
- **Designated avoiders** — people who shouldn't drive (impaired, no car, DUI
  paranoia) and want frictionless rideshare or walking routing

Cannabis is the wedge that anchors the brand. The product is "the buddy who
handles your night when you're too altered to handle it yourself."

## Travel modes (first-class, not optional)
Routing must work equally well for:
- **Walking** — late-night-home-from-bar is a core scenario. Use Mapbox
  `walking` profile. Corridor radius ~500m. Detour cap ~15 min (a 5-min walking
  detour is meaningful; 15 is the upper bound).
- **Driving** — Mapbox `driving-traffic` profile. Corridor radius ~3km. Detour
  cap ~30-60 min depending on baseline trip length.
- **Rideshare handoff** — Uber / Lyft / Waymo deep link from Results screen.
  Same routing math, different last-mile.

Travel mode is a toggle on the Home screen, persisted in store.

## Stack
- **Expo (React Native) + TypeScript** — single codebase, ships to iOS / Android / web
- **Expo Router** — file-based routing under `app/`
- **Mapbox** — `@rnmapbox/maps` on native, `mapbox-gl` on web. Maps + Directions
  + Matrix + Search Box. One vendor, one token.
- **Zustand** — lightweight app state (destination, toggles, results, saved
  destinations)
- **No backend in v0/v1** — saved destinations live in AsyncStorage on-device
  (privacy-preserving, no breach surface, no compliance footprint)

## Architecture
- `app/` — Expo Router routes (AgeGate, Home, Results, future: Friends grid)
- `src/screens/` — screen components mounted by routes
- `src/components/` — reusable presentational components (Pill, Button, StopCard, Map)
- `src/theme/` — colors, typography, spacing tokens. No inline magic numbers.
- `src/routing/` — pure functions for detour math and stop insertion
- `src/services/` — API clients. Mapbox calls when token present, mock data when absent.
- `src/services/mapbox/client.ts` — central Mapbox client (token + endpoints + UUID helper)
- `src/state/` — Zustand stores (app state, future: saved destinations)
- `src/types/` — shared TypeScript types

## Routing algorithm (the differentiator)
1. Compute baseline direct route: origin → destination via Mapbox Directions
2. Pre-filter candidates by route-corridor bounding box (radius depends on mode)
3. For each candidate, detour cost = (origin → stop → destination) − baseline
4. For dispensary + munchies combo: dispensary inserted before munchies
   (user wants munchies near destination, not before pickup)
5. Cap candidates at ~10 per category before insertion math; cache aggressively
6. Pin/swap: user can lock a specific stop; algorithm re-ranks the OTHER
   category around that constraint

## Design system
- Premium, restrained, dark-first. Think Linear / Arc / Things 3.
- Background: near-black (`#0A0A0A` family)
- Accent: warm amber. Never green for primary brand surfaces.
- Typography: Inter. Single family, weight does the work.
- Wordmark: lowercase `heybud`, no caps in UI copy.
- Animations: spring physics, slow. Premium feels unhurried.
- Haptics on iOS for selections and route updates.
- Map style: dark, desaturated, minimal labels. Route line as hero.

## Voice
Conversational, dry, confident. Never winks. No weed puns or emoji-as-personality.
Vocabulary: "dispensary" and "munchies" — own those words.

## Compliance
- 21+ age gate before any cannabis content (already gates `/home` after gate)
- Apple App Store has historically rejected cannabis apps — web app is the
  primary launch surface. Native apps follow once policy risk is cleared.
- Geofence dispensary results to legal states (TODO in dispensaries service)
- Display + handoff only. Do not facilitate purchase or delivery in-app.
- No incentivizing in-vehicle cannabis consumption (CVC 23222(b) etc.) — Uber /
  Waymo are nav options, not "hotbox" features.

## v0 (current scaffold)
Mock data, single-stop routing, dispensary + munchies categories, driving mode
only, web + Expo Go dev. Live at heybudhq.com via static export.

## v1 north star (the real product)
- **Saved destinations** — friends + spots in a unified photo grid. Tap a face
  or a place → instant route. Primary home-screen UX.
- **Walking mode** — first-class, with mode-aware corridor + detour caps.
- **Pin/swap stops** — user overrides algorithm picks via swap card.
- **Live Mapbox** — drop mocks, real Directions + Matrix + Search Box calls.
- **Native dev client** — Mapbox SDK on iOS/Android via custom dev client.
- **Rideshare handoff** — Uber / Lyft deep link from Results.
- **Settings: preferred nav** — saved once, one-tap handoff forever after.

## v2+ (the night-planning app)
- DoorDash / Uber Eats deep link: "deliver munchies to destination" instead of
  routing through a stop
- Waymo / Tesla Robotaxi as nav options (when geographic coverage is real)
- Personalization re-ranking (recommender, not LLM)
- Sync saved destinations across devices (introduces accounts + encryption)

## Out of scope (still, even at v1)
Accounts/login, in-app purchase or delivery, push notifications, deals/coupons,
social features, real-time friend location sharing, generated AI content,
self-trained ML models for the routing math (classical OR solves it).

## Coding standards
- TypeScript strict mode
- One component per file; filename matches export
- Functional components with hooks; no class components
- No default exports for components — named exports for greppability
- Theme tokens for all colors/spacing/typography; no inline hex or magic numbers
- Service layer returns typed data; UI never talks to APIs directly
- Comments only when the WHY is non-obvious
- All API responses parsed defensively (type-narrow unknown, never trust the wire)
