import {
  buildComboRoutes,
  detourCost,
  formatMinutes,
  rankCandidates,
} from '@/routing/detour';
import type { RankedStop, Stop } from '@/types';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function makeStop(id: string, category: Stop['category'] = 'dispensary'): Stop {
  return {
    id,
    name: `Stop ${id}`,
    category,
    location: { lat: 0, lng: 0 },
    address: '1 Test St',
  };
}

function makeRanked(id: string, detourMinutes: number, category: Stop['category'] = 'dispensary'): RankedStop {
  return { ...makeStop(id, category), detourMinutes };
}

// ---------------------------------------------------------------------------
// detourCost
// ---------------------------------------------------------------------------

describe('detourCost', () => {
  it('returns 0 when via is less than baseline (no negative detour)', () => {
    expect(detourCost(900, 600)).toBe(0);
  });

  it('returns correct minutes when via exceeds baseline', () => {
    // baseline 600 s, via 780 s → 180 s delta → 3 min
    expect(detourCost(600, 780)).toBe(3);
  });

  it('returns 0 for NaN inputs', () => {
    expect(detourCost(NaN, 780)).toBe(0);
    expect(detourCost(600, NaN)).toBe(0);
  });

  it('returns 0 for Infinity inputs', () => {
    expect(detourCost(Infinity, 780)).toBe(0);
    expect(detourCost(600, Infinity)).toBe(0);
  });

  it('returns 0 when via is not greater than baseline (negative delta)', () => {
    // via equal to baseline → no detour
    expect(detourCost(600, 600)).toBe(0);
    // via below baseline → clamped to 0
    expect(detourCost(600, 599)).toBe(0);
  });

  it('returns 0 for -Infinity produced by overflow', () => {
    // -Number.MAX_VALUE * 2 overflows to -Infinity, which is non-finite
    expect(detourCost(600, -Number.MAX_VALUE * 2)).toBe(0);
  });
});

// ---------------------------------------------------------------------------
// rankCandidates
// ---------------------------------------------------------------------------

describe('rankCandidates', () => {
  it('sorts stops ascending by detour minutes', () => {
    const stops = [makeStop('a'), makeStop('b'), makeStop('c')];
    // a = 10 min detour, b = 2 min, c = 6 min
    const durations = new Map([
      ['a', 600 + 600],   // 600 s baseline + 600 s extra = 10 min
      ['b', 600 + 120],   // 2 min
      ['c', 600 + 360],   // 6 min
    ]);
    const result = rankCandidates(stops, 600, durations);
    expect(result.map((s) => s.id)).toEqual(['b', 'c', 'a']);
  });

  it('skips candidates that have no entry in the duration map', () => {
    const stops = [makeStop('x'), makeStop('y')];
    const durations = new Map([['x', 900]]); // 'y' is absent
    const result = rankCandidates(stops, 600, durations);
    expect(result).toHaveLength(1);
    expect(result[0]?.id).toBe('x');
  });

  it('filters out candidates whose detour exceeds 60 minutes', () => {
    const stops = [makeStop('over'), makeStop('under')];
    const durations = new Map([
      ['over', 600 + 61 * 60],  // 61 min detour
      ['under', 600 + 5 * 60],  // 5 min detour
    ]);
    const result = rankCandidates(stops, 600, durations);
    expect(result).toHaveLength(1);
    expect(result[0]?.id).toBe('under');
  });

  it('returns an empty array for an empty candidates input', () => {
    expect(rankCandidates([], 600, new Map([['x', 900]]))).toEqual([]);
  });
});

// ---------------------------------------------------------------------------
// buildComboRoutes
// ---------------------------------------------------------------------------

describe('buildComboRoutes', () => {
  it('returns an empty array when both dispensaries and munchies are empty', () => {
    expect(buildComboRoutes([], [], 600, new Map())).toEqual([]);
  });

  it('returns dispensary-only combos when munchies array is empty', () => {
    const disps = [makeRanked('d1', 5), makeRanked('d2', 10)];
    const result = buildComboRoutes(disps, [], 600, new Map());
    expect(result).toHaveLength(2);
    expect(result.every((r) => r.stops.length === 1)).toBe(true);
    expect(result[0]?.stops[0]?.id).toBe('d1'); // sorted ascending
  });

  it('returns munchies-only combos when dispensaries array is empty', () => {
    const munch = [makeRanked('m1', 8, 'munchies'), makeRanked('m2', 3, 'munchies')];
    const result = buildComboRoutes([], munch, 600, new Map());
    expect(result).toHaveLength(2);
    expect(result[0]?.stops[0]?.id).toBe('m2'); // 3 min sorts first
  });

  it('pairs dispensaries with munchies and returns at most 5 combos sorted ascending by totalDetourMinutes', () => {
    // 3 dispensaries × 3 munchies = 9 pairs; all under 60 min via fallback sum
    const disps = [
      makeRanked('d1', 2),
      makeRanked('d2', 4),
      makeRanked('d3', 6),
    ];
    const munch = [
      makeRanked('m1', 1, 'munchies'),
      makeRanked('m2', 3, 'munchies'),
      makeRanked('m3', 5, 'munchies'),
    ];
    // No pair durations supplied → fallback to sum of legs
    const result = buildComboRoutes(disps, munch, 600, new Map());
    expect(result.length).toBeLessThanOrEqual(5);
    // Verify ascending order
    for (let i = 1; i < result.length; i++) {
      expect(result[i]!.totalDetourMinutes).toBeGreaterThanOrEqual(result[i - 1]!.totalDetourMinutes);
    }
  });

  it('places the dispensary stop before the munchies stop in the stops array', () => {
    const disps = [makeRanked('d1', 5)];
    const munch = [makeRanked('m1', 3, 'munchies')];
    const result = buildComboRoutes(disps, munch, 600, new Map());
    expect(result).toHaveLength(1);
    const stops = result[0]!.stops;
    expect(stops[0]?.category).toBe('dispensary');
    expect(stops[1]?.category).toBe('munchies');
  });
});

// ---------------------------------------------------------------------------
// formatMinutes
// ---------------------------------------------------------------------------

describe('formatMinutes', () => {
  it('formats values under 60 minutes as "+N min"', () => {
    expect(formatMinutes(3)).toBe('+3 min');
    expect(formatMinutes(12)).toBe('+12 min');
    expect(formatMinutes(0)).toBe('+0 min');
  });

  it('formats values over 60 minutes as "+N hr M min"', () => {
    expect(formatMinutes(65)).toBe('+1 hr 5 min');
    expect(formatMinutes(90)).toBe('+1 hr 30 min');
    expect(formatMinutes(120)).toBe('+2 hr');
  });
});
