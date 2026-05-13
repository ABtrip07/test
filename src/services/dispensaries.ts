import type { Corridor } from '@/routing/types';
import type { Stop } from '@/types';

// TODO: geofence to legal cannabis states/jurisdictions before shipping real data.
// Region check should happen here (and/or at the API gateway) so disallowed regions return [].

const MIN_LATENCY_MS = 50;
const MAX_LATENCY_MS = 150;

interface MockDispensary {
  id: string;
  name: string;
  address: string;
  rating: number;
  openNow: boolean;
  // Relative position inside corridor: 0..1 on each axis.
  u: number;
  v: number;
}

export const __MOCK_DISPENSARIES: MockDispensary[] = [
  { id: 'd_howard_st', name: 'Howard Street Dispensary', address: '843 Howard St', rating: 4.7, openNow: true, u: 0.15, v: 0.32 },
  { id: 'd_pathway', name: 'Pathway Dispensary', address: '12 Mission St', rating: 4.5, openNow: true, u: 0.32, v: 0.68 },
  { id: 'd_oak', name: 'The Oak Dispensary', address: '2210 Telegraph Ave', rating: 4.8, openNow: false, u: 0.48, v: 0.21 },
  { id: 'd_sequoia', name: 'Sequoia Cannabis Co.', address: '410 Divisadero St', rating: 4.6, openNow: true, u: 0.55, v: 0.55 },
  { id: 'd_meridian', name: 'Meridian Cannabis', address: '999 Folsom St', rating: 4.3, openNow: true, u: 0.62, v: 0.78 },
  { id: 'd_north_star', name: 'North Star Apothecary', address: '1755 Polk St', rating: 4.4, openNow: true, u: 0.71, v: 0.42 },
  { id: 'd_atlas', name: 'Atlas Cannabis', address: '88 4th St', rating: 3.9, openNow: false, u: 0.25, v: 0.84 },
  { id: 'd_quill', name: 'Quill & Leaf', address: '2400 Shattuck Ave', rating: 4.9, openNow: true, u: 0.83, v: 0.27 },
  { id: 'd_marin', name: 'Marin Botanicals', address: '88 Throckmorton Ave', rating: 4.2, openNow: true, u: 0.42, v: 0.12 },
  { id: 'd_lantern', name: 'Lantern Cannabis Club', address: '301 Valencia St', rating: 4.6, openNow: true, u: 0.18, v: 0.5 },
];

export async function findDispensariesInCorridor(corridor: Corridor): Promise<Stop[]> {
  try {
    await simulateLatency();
    if (!isValidCorridor(corridor)) return [];

    const latSpan = corridor.maxLat - corridor.minLat;
    const lngSpan = corridor.maxLng - corridor.minLng;
    if (!Number.isFinite(latSpan) || !Number.isFinite(lngSpan)) return [];

    return __MOCK_DISPENSARIES.map<Stop>((d) => ({
      id: d.id,
      name: d.name,
      category: 'dispensary',
      location: {
        lat: corridor.minLat + clamp01(d.v) * latSpan,
        lng: corridor.minLng + clamp01(d.u) * lngSpan,
      },
      address: d.address,
      rating: d.rating,
      openNow: d.openNow,
    }));
  } catch (err) {
    console.warn('[dispensaries.findDispensariesInCorridor] failed', err);
    return [];
  }
}

function isValidCorridor(c: Corridor | undefined | null): c is Corridor {
  if (!c) return false;
  return (
    Number.isFinite(c.minLat) &&
    Number.isFinite(c.maxLat) &&
    Number.isFinite(c.minLng) &&
    Number.isFinite(c.maxLng) &&
    c.maxLat >= c.minLat &&
    c.maxLng >= c.minLng
  );
}

function clamp01(v: number): number {
  if (!Number.isFinite(v)) return 0;
  return Math.max(0, Math.min(1, v));
}

async function simulateLatency(): Promise<void> {
  const ms = MIN_LATENCY_MS + Math.random() * (MAX_LATENCY_MS - MIN_LATENCY_MS);
  await new Promise((resolve) => setTimeout(resolve, ms));
}
