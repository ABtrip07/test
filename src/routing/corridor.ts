import type { LatLng } from '@/types';
import type { Corridor } from '@/routing/types';

const EARTH_RADIUS_KM = 6371;
const DEFAULT_PADDING_KM = 3;

/** Bounding-box corridor between origin and destination, padded by paddingKm. */
export function routeCorridor(origin: LatLng, destination: LatLng, paddingKm: number = DEFAULT_PADDING_KM): Corridor {
  assertValidLatLng(origin, 'origin');
  assertValidLatLng(destination, 'destination');
  const padKm = Number.isFinite(paddingKm) && paddingKm >= 0 ? paddingKm : DEFAULT_PADDING_KM;

  const minLat = Math.min(origin.lat, destination.lat);
  const maxLat = Math.max(origin.lat, destination.lat);
  const minLng = Math.min(origin.lng, destination.lng);
  const maxLng = Math.max(origin.lng, destination.lng);

  // Latitude: 1 deg ~= 111.32 km.
  const latPad = padKm / 111.32;
  // Longitude pad depends on latitude. Use the midpoint and guard near the poles.
  const midLat = (minLat + maxLat) / 2;
  const cosMid = Math.cos(toRadians(midLat));
  const lngPad = padKm / (111.32 * Math.max(0.0001, Math.abs(cosMid)));

  return {
    minLat: clampLat(minLat - latPad),
    maxLat: clampLat(maxLat + latPad),
    minLng: clampLng(minLng - lngPad),
    maxLng: clampLng(maxLng + lngPad),
  };
}

export function isInCorridor(point: LatLng, corridor: Corridor): boolean {
  if (!point || !corridor) return false;
  if (!Number.isFinite(point.lat) || !Number.isFinite(point.lng)) return false;
  if (
    !Number.isFinite(corridor.minLat) ||
    !Number.isFinite(corridor.maxLat) ||
    !Number.isFinite(corridor.minLng) ||
    !Number.isFinite(corridor.maxLng)
  ) {
    return false;
  }
  return (
    point.lat >= corridor.minLat &&
    point.lat <= corridor.maxLat &&
    point.lng >= corridor.minLng &&
    point.lng <= corridor.maxLng
  );
}

/** Great-circle distance in km. Returns 0 on invalid input. */
export function haversineKm(a: LatLng, b: LatLng): number {
  if (!a || !b) return 0;
  if (!Number.isFinite(a.lat) || !Number.isFinite(a.lng)) return 0;
  if (!Number.isFinite(b.lat) || !Number.isFinite(b.lng)) return 0;

  const dLat = toRadians(b.lat - a.lat);
  const dLng = toRadians(b.lng - a.lng);
  const lat1 = toRadians(a.lat);
  const lat2 = toRadians(b.lat);

  const sinDLat = Math.sin(dLat / 2);
  const sinDLng = Math.sin(dLng / 2);
  const h = sinDLat * sinDLat + Math.cos(lat1) * Math.cos(lat2) * sinDLng * sinDLng;
  const c = 2 * Math.atan2(Math.sqrt(h), Math.sqrt(Math.max(0, 1 - h)));
  const km = EARTH_RADIUS_KM * c;
  return Number.isFinite(km) ? km : 0;
}

function assertValidLatLng(p: LatLng, label: string): void {
  if (!p || !Number.isFinite(p.lat) || !Number.isFinite(p.lng)) {
    throw new Error(`Invalid LatLng for ${label}`);
  }
  if (p.lat < -90 || p.lat > 90 || p.lng < -180 || p.lng > 180) {
    throw new Error(`Out-of-range LatLng for ${label}`);
  }
}

function toRadians(deg: number): number {
  return (deg * Math.PI) / 180;
}

function clampLat(v: number): number {
  return Math.max(-90, Math.min(90, v));
}

function clampLng(v: number): number {
  return Math.max(-180, Math.min(180, v));
}
