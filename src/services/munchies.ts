import { MUNCHIE_CATEGORIES, type MunchieCategory } from '@/constants/munchieCategories';
import type { Corridor } from '@/routing/types';
import type { Stop } from '@/types';

const MIN_LATENCY_MS = 50;
const MAX_LATENCY_MS = 150;

interface MockMunchie {
  id: string;
  name: string;
  address: string;
  rating: number;
  openNow: boolean;
  subtype: MunchieCategory;
  u: number;
  v: number;
}

export const __MOCK_MUNCHIES: MockMunchie[] = [
  { id: 'm_taco_bell', name: 'Taco Bell', address: '1325 Mission St', rating: 3.8, openNow: true, subtype: 'fast_food', u: 0.12, v: 0.22 },
  { id: 'm_innout', name: 'In-N-Out Burger', address: '333 Jefferson St', rating: 4.6, openNow: true, subtype: 'fast_food', u: 0.28, v: 0.41 },
  { id: 'm_seven_eleven', name: '7-Eleven', address: '900 Bryant St', rating: 3.6, openNow: true, subtype: 'convenience_store', u: 0.36, v: 0.18 },
  { id: 'm_joes_pizza', name: "Joe's Pizza", address: '180 Geary St', rating: 4.5, openNow: true, subtype: 'pizza', u: 0.47, v: 0.55 },
  { id: 'm_mister_donut', name: 'Mister Donut', address: '2299 Mission St', rating: 4.2, openNow: false, subtype: 'donut', u: 0.55, v: 0.74 },
  { id: 'm_humphry', name: 'Humphry Slocombe', address: '2790A Harrison St', rating: 4.7, openNow: true, subtype: 'ice_cream', u: 0.61, v: 0.33 },
  { id: 'm_ippudo', name: 'Ippudo Ramen', address: '410 Sutter St', rating: 4.4, openNow: true, subtype: 'ramen', u: 0.68, v: 0.62 },
  { id: 'm_boba_guys', name: 'Boba Guys', address: '429 Stockton St', rating: 4.5, openNow: true, subtype: 'boba', u: 0.74, v: 0.28 },
  { id: 'm_late_night_diner', name: 'Orphan Andy’s', address: '3991 17th St', rating: 4.1, openNow: true, subtype: 'late_night', u: 0.82, v: 0.49 },
  { id: 'm_chevron', name: 'Chevron ExtraMile', address: '699 8th St', rating: 3.4, openNow: true, subtype: 'gas_station_hot_food', u: 0.21, v: 0.85 },
  { id: 'm_mcdonalds', name: "McDonald's", address: '701 3rd St', rating: 3.7, openNow: true, subtype: 'fast_food', u: 0.39, v: 0.66 },
  { id: 'm_circle_k', name: 'Circle K', address: '1600 Folsom St', rating: 3.5, openNow: true, subtype: 'convenience_store', u: 0.52, v: 0.13 },
  { id: 'm_arinell', name: 'Arinell Pizza', address: '509 Valencia St', rating: 4.3, openNow: true, subtype: 'pizza', u: 0.66, v: 0.81 },
  { id: 'm_bobs_donuts', name: "Bob's Donuts", address: '1621 Polk St', rating: 4.6, openNow: true, subtype: 'donut', u: 0.78, v: 0.7 },
  { id: 'm_mitchells', name: "Mitchell's Ice Cream", address: '688 San Jose Ave', rating: 4.7, openNow: false, subtype: 'ice_cream', u: 0.9, v: 0.4 },
];

export async function findMunchiesInCorridor(corridor: Corridor): Promise<Stop[]> {
  try {
    await simulateLatency();
    if (!isValidCorridor(corridor)) return [];

    const latSpan = corridor.maxLat - corridor.minLat;
    const lngSpan = corridor.maxLng - corridor.minLng;
    if (!Number.isFinite(latSpan) || !Number.isFinite(lngSpan)) return [];

    return __MOCK_MUNCHIES.map<Stop>((m) => ({
      id: m.id,
      name: m.name,
      category: 'munchies',
      location: {
        lat: corridor.minLat + clamp01(m.v) * latSpan,
        lng: corridor.minLng + clamp01(m.u) * lngSpan,
      },
      address: m.address,
      rating: m.rating,
      openNow: m.openNow,
      subtype: isKnownMunchieCategory(m.subtype) ? m.subtype : undefined,
    }));
  } catch (err) {
    console.warn('[munchies.findMunchiesInCorridor] failed', err);
    return [];
  }
}

function isKnownMunchieCategory(value: string): value is MunchieCategory {
  return (MUNCHIE_CATEGORIES as readonly string[]).includes(value);
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
