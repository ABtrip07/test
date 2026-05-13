import type { LatLng, Place } from '@/types';
import {
  MAPBOX_ENDPOINTS,
  hasMapboxToken,
  mapboxUrl,
  uuid,
} from '@/services/mapbox/client';

// When EXPO_PUBLIC_MAPBOX_ACCESS_TOKEN is set, real Mapbox Search Box calls.
// When absent, falls back to a curated mock list so dev runs without a key.

const MIN_LATENCY_MS = 50;
const MAX_LATENCY_MS = 150;

export const __MOCK_PLACES: Place[] = [
  { id: 'p_home', name: 'Home', address: '1422 Larkspur Ln, Oakland, CA', location: { lat: 37.8123, lng: -122.2541 } },
  { id: 'p_work', name: 'Work', address: '500 Market St, San Francisco, CA', location: { lat: 37.7894, lng: -122.4012 } },
  { id: 'p_ferry', name: 'Ferry Building', address: '1 Ferry Building, San Francisco, CA', location: { lat: 37.7956, lng: -122.3933 } },
  { id: 'p_dolores', name: "Mom's House", address: '2100 Dolores St, San Francisco, CA', location: { lat: 37.7536, lng: -122.4253 } },
  { id: 'p_berkeley', name: 'Berkeley Campus', address: 'University Dr, Berkeley, CA', location: { lat: 37.8719, lng: -122.2585 } },
  { id: 'p_airport', name: 'SFO Airport', address: 'San Francisco Intl Airport, CA', location: { lat: 37.6213, lng: -122.379 } },
  { id: 'p_marina', name: 'Marina Green', address: '500 Marina Blvd, San Francisco, CA', location: { lat: 37.806, lng: -122.4422 } },
  { id: 'p_gym', name: 'The Gym', address: '845 Market St, San Francisco, CA', location: { lat: 37.7837, lng: -122.4072 } },
];

// One session token per autocomplete session. Mapbox bills one session as
// suggest calls + a single retrieve. Reset after a place is selected.
let sessionToken: string | null = null;
function getSessionToken(): string {
  if (sessionToken === null) sessionToken = uuid();
  return sessionToken;
}
export function resetSearchSession(): void {
  sessionToken = null;
}

export async function searchPlaces(query: string, near?: LatLng): Promise<Place[]> {
  if (typeof query !== 'string' || query.trim().length === 0) return [];
  if (hasMapboxToken()) return searchPlacesLive(query, near);
  return searchPlacesMock(query, near);
}

export async function getPlaceDetails(placeId: string): Promise<Place | null> {
  if (typeof placeId !== 'string' || placeId.length === 0) return null;
  if (hasMapboxToken()) return getPlaceDetailsLive(placeId);
  return getPlaceDetailsMock(placeId);
}

// -------------------- LIVE --------------------

async function searchPlacesLive(query: string, near?: LatLng): Promise<Place[]> {
  try {
    const params: Record<string, string> = {
      q: query,
      session_token: getSessionToken(),
      language: 'en',
      limit: '5',
    };
    if (near && Number.isFinite(near.lat) && Number.isFinite(near.lng)) {
      params.proximity = `${near.lng},${near.lat}`;
    }
    const url = mapboxUrl(MAPBOX_ENDPOINTS.searchSuggest, params);
    const resp = await fetch(url);
    if (!resp.ok) {
      console.warn('[places.searchPlacesLive] non-2xx', resp.status);
      return [];
    }
    const data: unknown = await resp.json();
    return parseSuggestions(data);
  } catch (err) {
    console.warn('[places.searchPlacesLive] failed', err);
    return [];
  }
}

async function getPlaceDetailsLive(placeId: string): Promise<Place | null> {
  try {
    const path = `${MAPBOX_ENDPOINTS.searchRetrieve}/${encodeURIComponent(placeId)}`;
    const url = mapboxUrl(path, { session_token: getSessionToken() });
    const resp = await fetch(url);
    if (!resp.ok) {
      console.warn('[places.getPlaceDetailsLive] non-2xx', resp.status);
      return null;
    }
    const data: unknown = await resp.json();
    const place = parseRetrievedPlace(data);
    // A successful retrieve closes the billed session.
    if (place !== null) resetSearchSession();
    return place;
  } catch (err) {
    console.warn('[places.getPlaceDetailsLive] failed', err);
    return null;
  }
}

interface MapboxSuggestion {
  name: string;
  mapbox_id: string;
  full_address?: string;
  place_formatted?: string;
}

function parseSuggestions(data: unknown): Place[] {
  if (typeof data !== 'object' || data === null) return [];
  const suggestions = (data as { suggestions?: unknown }).suggestions;
  if (!Array.isArray(suggestions)) return [];
  const out: Place[] = [];
  for (const s of suggestions) {
    if (typeof s !== 'object' || s === null) continue;
    const obj = s as Partial<MapboxSuggestion>;
    if (typeof obj.mapbox_id !== 'string' || typeof obj.name !== 'string') continue;
    // Suggest does not return coordinates; we surface the suggestion with a
    // placeholder location of (0,0). Coordinates are filled in by getPlaceDetails
    // when the user selects this suggestion.
    out.push({
      id: obj.mapbox_id,
      name: obj.name,
      address: obj.full_address ?? obj.place_formatted ?? '',
      location: { lat: 0, lng: 0 },
    });
  }
  return out;
}

function parseRetrievedPlace(data: unknown): Place | null {
  if (typeof data !== 'object' || data === null) return null;
  const features = (data as { features?: unknown }).features;
  if (!Array.isArray(features) || features.length === 0) return null;
  const f = features[0];
  if (typeof f !== 'object' || f === null) return null;
  const props = (f as { properties?: unknown }).properties;
  const geom = (f as { geometry?: unknown }).geometry;
  if (typeof props !== 'object' || props === null) return null;
  if (typeof geom !== 'object' || geom === null) return null;
  const coords = (geom as { coordinates?: unknown }).coordinates;
  if (!Array.isArray(coords) || coords.length < 2) return null;
  const lng = coords[0];
  const lat = coords[1];
  if (typeof lng !== 'number' || typeof lat !== 'number') return null;
  if (!Number.isFinite(lng) || !Number.isFinite(lat)) return null;
  const name = (props as { name?: unknown }).name;
  const fullAddress = (props as { full_address?: unknown }).full_address;
  const placeFormatted = (props as { place_formatted?: unknown }).place_formatted;
  const mapboxId = (props as { mapbox_id?: unknown }).mapbox_id;
  return {
    id: typeof mapboxId === 'string' ? mapboxId : uuid(),
    name: typeof name === 'string' ? name : 'place',
    address:
      typeof fullAddress === 'string'
        ? fullAddress
        : typeof placeFormatted === 'string'
          ? placeFormatted
          : '',
    location: { lat, lng },
  };
}

// -------------------- MOCK --------------------

async function searchPlacesMock(query: string, near?: LatLng): Promise<Place[]> {
  try {
    await simulateLatency();
    const q = query.trim().toLowerCase();
    const matches = __MOCK_PLACES.filter(
      (p) => p.name.toLowerCase().includes(q) || p.address.toLowerCase().includes(q),
    );
    if (near && Number.isFinite(near.lat) && Number.isFinite(near.lng)) {
      matches.sort((a, b) => squaredDist(a.location, near) - squaredDist(b.location, near));
    }
    return matches.slice(0, 5);
  } catch (err) {
    console.warn('[places.searchPlacesMock] failed', err);
    return [];
  }
}

async function getPlaceDetailsMock(placeId: string): Promise<Place | null> {
  try {
    await simulateLatency();
    return __MOCK_PLACES.find((p) => p.id === placeId) ?? null;
  } catch (err) {
    console.warn('[places.getPlaceDetailsMock] failed', err);
    return null;
  }
}

function squaredDist(a: LatLng, b: LatLng): number {
  const dLat = a.lat - b.lat;
  const dLng = a.lng - b.lng;
  return dLat * dLat + dLng * dLng;
}

async function simulateLatency(): Promise<void> {
  const ms = MIN_LATENCY_MS + Math.random() * (MAX_LATENCY_MS - MIN_LATENCY_MS);
  await new Promise((resolve) => setTimeout(resolve, ms));
}
