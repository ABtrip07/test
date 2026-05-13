// Central Mapbox API client. All Mapbox HTTP calls flow through here so the
// token, base URL, and request defaults live in one place. Services consume
// this module instead of reaching for process.env directly.

const TOKEN = process.env.EXPO_PUBLIC_MAPBOX_ACCESS_TOKEN ?? '';

export const MAPBOX_BASE_URL = 'https://api.mapbox.com';

export function hasMapboxToken(): boolean {
  return TOKEN.length > 0;
}

export function mapboxUrl(path: string, params: Record<string, string> = {}): string {
  const url = new URL(`${MAPBOX_BASE_URL}${path}`);
  url.searchParams.set('access_token', TOKEN);
  for (const [k, v] of Object.entries(params)) {
    if (v.length > 0) url.searchParams.set(k, v);
  }
  return url.toString();
}

// Endpoints we plan to use. Centralized so services reference one source of truth.
export const MAPBOX_ENDPOINTS = {
  directions: '/directions/v5/mapbox/driving-traffic',
  matrix: '/directions-matrix/v1/mapbox/driving-traffic',
  searchSuggest: '/search/searchbox/v1/suggest',
  searchRetrieve: '/search/searchbox/v1/retrieve',
} as const;

// Cheap, non-cryptographic UUID v4 — fine for Mapbox session tokens, which
// only need to be unique per autocomplete session (one billed unit per session).
export function uuid(): string {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0;
    const v = c === 'x' ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
}
