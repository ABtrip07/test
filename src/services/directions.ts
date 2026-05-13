import { haversineKm } from '@/routing/corridor';
import type { RouteRequest, RouteResponse } from '@/routing/types';
import type { LatLng } from '@/types';

const MIN_LATENCY_MS = 50;
const MAX_LATENCY_MS = 150;
const AVG_CITY_SPEED_KMH = 40;

export async function getRoute(req: RouteRequest): Promise<RouteResponse | null> {
  try {
    await simulateLatency();
    if (!isValidRequest(req)) return null;

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

    return {
      duration: { seconds },
      distanceMeters,
    };
  } catch (err) {
    console.warn('[directions.getRoute] failed', err);
    return null;
  }
}

export async function getRouteBatch(reqs: RouteRequest[]): Promise<(RouteResponse | null)[]> {
  try {
    if (!Array.isArray(reqs) || reqs.length === 0) return [];
    const results = await Promise.all(reqs.map((r) => safeGetRoute(r)));
    return results;
  } catch (err) {
    console.warn('[directions.getRouteBatch] failed', err);
    return Array.isArray(reqs) ? reqs.map(() => null) : [];
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
