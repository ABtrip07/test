import { haversineKm } from '@/routing/corridor';
import type { RouteRequest, RouteResponse } from '@/routing/types';
import type { LatLng } from '@/types';
import {
  MAPBOX_ENDPOINTS,
  hasMapboxToken,
  mapboxUrl,
} from '@/services/mapbox/client';

// When EXPO_PUBLIC_MAPBOX_ACCESS_TOKEN is set, real Mapbox Directions calls.
// When absent, falls back to a haversine-based mock so dev runs without a key.

const MIN_LATENCY_MS = 50;
const MAX_LATENCY_MS = 150;
const AVG_CITY_SPEED_KMH = 40;

export async function getRoute(req: RouteRequest): Promise<RouteResponse | null> {
  if (!isValidRequest(req)) return null;
  if (hasMapboxToken()) {
    return getRouteLive(req);
  }
  return getRouteMock(req);
}

export async function getRouteBatch(reqs: RouteRequest[]): Promise<(RouteResponse | null)[]> {
  if (!Array.isArray(reqs) || reqs.length === 0) return [];
  try {
    const results = await Promise.all(reqs.map((r) => safeGetRoute(r)));
    return results;
  } catch (err) {
    console.warn('[directions.getRouteBatch] failed', err);
    return reqs.map(() => null);
  }
}

async function safeGetRoute(req: RouteRequest): Promise<RouteResponse | null> {
  try {
    return await getRoute(req);
  } catch (err) {
    console.warn('[directions.getRouteBatch] item failed', err);
    return null;
  }
}

async function getRouteLive(req: RouteRequest): Promise<RouteResponse | null> {
  try {
    const points: LatLng[] = [req.origin, ...(req.waypoints ?? []), req.destination];
    // Mapbox uses lng,lat order separated by semicolons.
    const coords = points.map((p) => `${p.lng},${p.lat}`).join(';');
    const url = mapboxUrl(`${MAPBOX_ENDPOINTS.directions}/${coords}`, {
      geometries: 'geojson',
      overview: 'simplified',
      annotations: 'duration,distance',
    });
    const resp = await fetch(url);
    if (!resp.ok) {
      console.warn('[directions.getRouteLive] non-2xx', resp.status);
      return null;
    }
    const data: unknown = await resp.json();
    const route = pickFirstRoute(data);
    if (route === null) return null;
    return {
      duration: { seconds: Math.max(0, Math.round(route.duration)) },
      distanceMeters: Math.max(0, Math.round(route.distance)),
    };
  } catch (err) {
    console.warn('[directions.getRouteLive] failed', err);
    return null;
  }
}

interface MapboxRoute {
  duration: number;
  distance: number;
}

function pickFirstRoute(data: unknown): MapboxRoute | null {
  if (typeof data !== 'object' || data === null) return null;
  const routes = (data as { routes?: unknown }).routes;
  if (!Array.isArray(routes) || routes.length === 0) return null;
  const r = routes[0];
  if (typeof r !== 'object' || r === null) return null;
  const duration = (r as { duration?: unknown }).duration;
  const distance = (r as { distance?: unknown }).distance;
  if (typeof duration !== 'number' || !Number.isFinite(duration)) return null;
  if (typeof distance !== 'number' || !Number.isFinite(distance)) return null;
  return { duration, distance };
}

async function getRouteMock(req: RouteRequest): Promise<RouteResponse | null> {
  try {
    await simulateLatency();
    const points: LatLng[] = [req.origin, ...(req.waypoints ?? []), req.destination];
    let totalKm = 0;
    for (let i = 0; i < points.length - 1; i += 1) {
      const a = points[i];
      const b = points[i + 1];
      if (!a || !b) continue;
      totalKm += haversineKm(a, b);
    }
    if (!Number.isFinite(totalKm) || totalKm < 0) totalKm = 0;

    const hours = totalKm / Math.max(1, AVG_CITY_SPEED_KMH);
    const seconds = Math.max(0, Math.round(hours * 3600));
    const distanceMeters = Math.max(0, Math.round(totalKm * 1000));

    return { duration: { seconds }, distanceMeters };
  } catch (err) {
    console.warn('[directions.getRouteMock] failed', err);
    return null;
  }
}

function isValidRequest(req: RouteRequest): boolean {
  if (!req) return false;
  if (!isFiniteLatLng(req.origin) || !isFiniteLatLng(req.destination)) return false;
  if (req.waypoints !== undefined && !Array.isArray(req.waypoints)) return false;
  if (Array.isArray(req.waypoints)) {
    for (const wp of req.waypoints) {
      if (!isFiniteLatLng(wp)) return false;
    }
  }
  return true;
}

function isFiniteLatLng(p: LatLng | undefined): p is LatLng {
  return !!p && Number.isFinite(p.lat) && Number.isFinite(p.lng);
}

async function simulateLatency(): Promise<void> {
  const ms = MIN_LATENCY_MS + Math.random() * (MAX_LATENCY_MS - MIN_LATENCY_MS);
  await new Promise((resolve) => setTimeout(resolve, ms));
}
