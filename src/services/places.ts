import type { LatLng, Place } from '@/types';

// Real implementation will call Mapbox Search Box:
//   GET /search/searchbox/v1/suggest?q=...    (autocomplete)
//   GET /search/searchbox/v1/retrieve/{id}    (place details)
// See @/services/mapbox/client for endpoint constants and token plumbing.
// v0 returns filtered mock places so the UI flow works without a token.

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

export async function searchPlaces(query: string, near?: LatLng): Promise<Place[]> {
  try {
    await simulateLatency();
    if (typeof query !== 'string') return [];
    const q = query.trim().toLowerCase();
    if (q.length === 0) return [];

    const matches = __MOCK_PLACES.filter(
      (p) => p.name.toLowerCase().includes(q) || p.address.toLowerCase().includes(q),
    );

    if (near && Number.isFinite(near.lat) && Number.isFinite(near.lng)) {
      matches.sort((a, b) => squaredDist(a.location, near) - squaredDist(b.location, near));
    }

    // Autocomplete-style: 3-5 results.
    return matches.slice(0, 5);
  } catch (err) {
    console.warn('[places.searchPlaces] failed', err);
    return [];
  }
}

export async function getPlaceDetails(placeId: string): Promise<Place | null> {
  try {
    await simulateLatency();
    if (typeof placeId !== 'string' || placeId.length === 0) return null;
    const found = __MOCK_PLACES.find((p) => p.id === placeId);
    return found ?? null;
  } catch (err) {
    console.warn('[places.getPlaceDetails] failed', err);
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
