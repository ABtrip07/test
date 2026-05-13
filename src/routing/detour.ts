import type { ComboRoute, RankedStop, Stop } from '@/types';

const MAX_DETOUR_MINUTES = 60;
const MAX_PAIR_COUNT = 100;
const TOP_COMBO_COUNT = 5;

/** Minutes added by a detour. Clamped at 0; non-finite inputs return 0. */
export function detourCost(baselineSeconds: number, viaSeconds: number): number {
  if (!Number.isFinite(baselineSeconds) || !Number.isFinite(viaSeconds)) return 0;
  const deltaSeconds = viaSeconds - baselineSeconds;
  if (!Number.isFinite(deltaSeconds) || deltaSeconds <= 0) return 0;
  return deltaSeconds / 60;
}

/** Rank candidate stops by detour minutes ascending. Filters missing/over-cap entries. */
export function rankCandidates(
  candidates: Stop[],
  baselineSeconds: number,
  durationsByStopId: Map<string, number>,
): RankedStop[] {
  if (!Array.isArray(candidates) || candidates.length === 0) return [];
  if (!(durationsByStopId instanceof Map) || durationsByStopId.size === 0) return [];
  if (!Number.isFinite(baselineSeconds)) return [];

  const ranked: RankedStop[] = [];
  for (const stop of candidates) {
    if (!stop || typeof stop.id !== 'string') continue;
    const via = durationsByStopId.get(stop.id);
    if (typeof via !== 'number' || !Number.isFinite(via)) continue;
    const minutes = detourCost(baselineSeconds, via);
    const rounded = Math.round(minutes);
    if (rounded > MAX_DETOUR_MINUTES) continue;
    ranked.push({ ...stop, detourMinutes: rounded });
  }

  ranked.sort((a, b) => a.detourMinutes - b.detourMinutes);
  return ranked;
}

/** Build combo routes: dispensary first, then munchies. Top 5 by total detour. */
export function buildComboRoutes(
  dispensaries: RankedStop[],
  munchies: RankedStop[],
  baselineSeconds: number,
  pairDurationsByKey: Map<string, number>,
): ComboRoute[] {
  const safeDisp = Array.isArray(dispensaries) ? dispensaries.filter(isValidRanked) : [];
  const safeMunch = Array.isArray(munchies) ? munchies.filter(isValidRanked) : [];
  const safePairs = pairDurationsByKey instanceof Map ? pairDurationsByKey : new Map<string, number>();
  const baselineMinutes = Number.isFinite(baselineSeconds)
    ? Math.max(0, Math.round(baselineSeconds / 60))
    : 0;

  if (safeDisp.length === 0 && safeMunch.length === 0) return [];

  const combos: ComboRoute[] = [];

  if (safeDisp.length === 0) {
    for (const m of safeMunch) {
      combos.push(makeCombo([m], m.detourMinutes, baselineMinutes));
    }
  } else if (safeMunch.length === 0) {
    for (const d of safeDisp) {
      combos.push(makeCombo([d], d.detourMinutes, baselineMinutes));
    }
  } else {
    // Cap before sort to bound work.
    let pairsConsidered = 0;
    outer: for (const d of safeDisp) {
      for (const m of safeMunch) {
        if (pairsConsidered >= MAX_PAIR_COUNT) break outer;
        pairsConsidered += 1;
        const key = `${d.id}|${m.id}`;
        const pairSeconds = safePairs.get(key);
        let totalDetour: number;
        if (typeof pairSeconds === 'number' && Number.isFinite(pairSeconds)) {
          totalDetour = Math.round(detourCost(baselineSeconds, pairSeconds));
        } else {
          // Fallback: sum of legs as a conservative upper estimate.
          totalDetour = d.detourMinutes + m.detourMinutes;
        }
        if (totalDetour > MAX_DETOUR_MINUTES) continue;
        combos.push(makeCombo([d, m], totalDetour, baselineMinutes));
      }
    }
  }

  combos.sort((a, b) => a.totalDetourMinutes - b.totalDetourMinutes);
  return combos.slice(0, TOP_COMBO_COUNT);
}

/** Human-readable detour string. */
export function formatMinutes(minutes: number): string {
  if (!Number.isFinite(minutes)) return '+0 min';
  const m = Math.max(0, Math.round(minutes));
  if (m < 60) return `+${m} min`;
  const hours = Math.floor(m / 60);
  const rem = m - hours * 60;
  if (rem === 0) return `+${hours} hr`;
  return `+${hours} hr ${rem} min`;
}

function isValidRanked(s: RankedStop | undefined | null): s is RankedStop {
  return !!s && typeof s.id === 'string' && Number.isFinite(s.detourMinutes);
}

function makeCombo(stops: RankedStop[], totalDetour: number, baselineMinutes: number): ComboRoute {
  const detour = Math.max(0, Math.round(totalDetour));
  const id = stops.map((s) => s.id).join('+');
  return {
    id,
    stops,
    totalDetourMinutes: detour,
    baselineMinutes,
    totalMinutes: baselineMinutes + detour,
  };
}
