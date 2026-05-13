# heybud

Dispensaries and munchies, on the way.

---

## Status

v0 scaffold. Mock data only — no real APIs wired. Structure, routing math, and UI
skeleton are in place. Ready for API keys and live data.

## What it does

Enter a destination and heybud computes a baseline route, then finds dispensaries
and munchie stops that fall along the way. Each stop is ranked by detour cost —
minutes added to the trip — not by raw distance. Toggle dispensaries, munchies, or
both to get a combined route with stops ordered correctly: dispensary first, munchies
near the destination. The top five route combinations are surfaced, sorted from least
to most added time.

## Tech

- **Expo SDK 51** — managed workflow, iOS, Android, and web targets.
- **Expo Router** — file-system routing under `app/`.
- **TypeScript strict** — `strict: true`, `noUncheckedIndexedAccess`, `noImplicitOverride`.
- **Mapbox** — `@rnmapbox/maps` on native, `mapbox-gl` on web. Faster and more customizable than Google Maps; fully restyleable to match heybud's dark aesthetic.
- **Google Maps Platform** — Directions API and Places Autocomplete for routing and search (Google's coverage beats Mapbox's for these specifically).
- **Zustand** — lightweight app state (destination, toggles, results).

## Project structure

```
app/                  Expo Router screens (AgeGate, Home, Results)
src/
  components/         Reusable presentational components
  routing/            Pure detour math and stop-insertion logic
  services/           API clients (directions, places, dispensaries) — stubbed
  state/              Zustand store
  theme/              Color, spacing, and typography tokens
  types/              Shared TypeScript types
__tests__/            Jest unit tests
```

## Getting started

```
npm install
cp .env.example .env  # add keys later
npx expo start
```

heybud runs on iOS, Android, and web from the same codebase. In the Metro CLI:
press `i` for iOS Simulator, `a` for Android Emulator, `w` for web, or scan the
QR with Expo Go on a phone.

Note: `@rnmapbox/maps` requires a custom dev client on native (`npx expo run:ios`
or `npx expo run:android`) — Expo Go can't load Mapbox's native module. The mock
data flow works in Expo Go and on web without a dev client; only the actual map
surface needs one. Web uses `mapbox-gl` and works without any native build.

## Environment variables

Copy `.env.example` to `.env` and fill in values before using live data.

| Variable | Purpose |
|---|---|
| `EXPO_PUBLIC_GOOGLE_MAPS_API_KEY` | Google Maps Platform — Directions API + Places Autocomplete |
| `EXPO_PUBLIC_MAPBOX_ACCESS_TOKEN` | Mapbox — map rendering on native and web |
| `EXPO_PUBLIC_WEEDMAPS_API_KEY` | Dispensary listings (deferred — v0 uses curated Google Places results) |

## Routing algorithm

The detour ranking is the core differentiator:

- Compute baseline: origin → destination via Google Directions.
- Pre-filter candidates to a bounding-box corridor around the route.
- For each candidate stop, detour cost = (origin → stop → destination) − baseline, converted to minutes and clamped at zero.
- Stops with detour > 60 minutes are dropped.
- For combined dispensary + munchies routes, the dispensary is inserted first (pickup before the munchie stop near the destination).
- Combo routes are ranked by total detour ascending; the top 5 are returned.

## Out of scope for v0

- Accounts, favorites, history
- Pre-order or in-app purchase
- Push notifications
- Deals and promotions
- Reviews and ratings
- Social features
- Multi-stop routing beyond one dispensary + one munchies stop

## Roadmap

- **v1: Real APIs** — wire Google Maps Platform + Mapbox; replace service stubs with live calls.
- **v1: Web parity** — primary launch surface is heybudhq.com (no App Store gate). Native apps follow once policy risk is cleared.
- **v1: Live preview map + nav handoff** — render route + stop pins inside heybud; one-tap handoff to user's preferred nav (Google Maps / Apple Maps / Waze).
- **v1: Persistence** — AsyncStorage for recent destinations and user preferences.
- **v1: Multi-stop** — support more than one dispensary or munchie stop per route.
- **v2: Pre-order integration** — deep link or handoff to dispensary ordering flow.
- **v2: Deals** — surface active promotions alongside stop cards.

## Compliance

- **21+ gate** — age verification screen before any cannabis content is shown.
- **No in-app purchase** — display and handoff only; no purchase facilitation.
- **Geofence dispensaries** — results must be restricted to legal states. TODO: implement geofence filter in dispensary service.
- **App Store risk** — Apple has historically rejected cannabis apps. Research current App Store policy before submitting. A web app or sideload distribution may be required initially.

## Scripts

| Command | What it does |
|---|---|
| `npm start` | Start the Expo dev server |
| `npm run typecheck` | Run `tsc --noEmit` for type checking without building |
| `npm test` | Run Jest unit tests |
