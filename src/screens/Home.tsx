import React, { useState, useRef, useCallback, useEffect } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';

import { Button } from '@/components/Button';
import { Pill } from '@/components/Pill';
import { DestinationInput } from '@/components/DestinationInput';
import { colors } from '@/theme/colors';
import { typography } from '@/theme/typography';
import { spacing } from '@/theme/spacing';
import { useAppStore } from '@/state/store';
import { searchPlaces } from '@/services/places';
import { findDispensariesInCorridor } from '@/services/dispensaries';
import { findMunchiesInCorridor } from '@/services/munchies';
import { getRouteBatch } from '@/services/directions';
import { routeCorridor } from '@/routing/corridor';
import { rankCandidates, buildComboRoutes } from '@/routing/detour';
import type { Place, LatLng } from '@/types';
import type { RouteRequest } from '@/routing/types';

/** Fallback origin (SF) used until real geolocation is wired in. */
const FALLBACK_ORIGIN: LatLng = { lat: 37.7749, lng: -122.4194 };

const DEBOUNCE_MS = 250;

export function Home() {
  const destination = useAppStore((s) => s.destination);
  const toggles = useAppStore((s) => s.toggles);
  const loading = useAppStore((s) => s.loading);
  const setDestination = useAppStore((s) => s.setDestination);
  const toggleCategory = useAppStore((s) => s.toggleCategory);
  const setLoading = useAppStore((s) => s.setLoading);
  const setResults = useAppStore((s) => s.setResults);
  const origin = useAppStore((s) => s.origin);
  const ageVerified = useAppStore((s) => s.ageVerified);

  const [query, setQuery] = useState<string>(destination?.name ?? '');
  const [suggestions, setSuggestions] = useState<Place[]>([]);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  // Stale-response guards. Search has its own; Find-stops has its own.
  // Each call increments the counter and discards its result if the counter
  // advanced while the request was in flight.
  const searchToken = useRef<number>(0);
  const findStopsToken = useRef<number>(0);
  const debounceTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  // Clear suggestions when a place is explicitly selected.
  function handleSelectPlace(place: Place) {
    setQuery(place.name);
    setSuggestions([]);
    setDestination(place);
  }

  function handleChangeText(text: string) {
    setQuery(text);
    // Clear destination selection when the user edits the field manually.
    if (destination !== null) {
      setDestination(null);
    }

    if (debounceTimer.current !== null) {
      clearTimeout(debounceTimer.current);
    }

    if (text.trim().length === 0) {
      setSuggestions([]);
      return;
    }

    const token = ++searchToken.current;

    debounceTimer.current = setTimeout(async () => {
      try {
        const results = await searchPlaces(text, origin ?? FALLBACK_ORIGIN);
        // Discard if a newer search was already fired.
        if (searchToken.current !== token) return;
        setSuggestions(Array.isArray(results) ? results : []);
      } catch {
        if (searchToken.current !== token) return;
        setSuggestions([]);
      }
    }, DEBOUNCE_MS);
  }

  // Clean up pending debounce timer on unmount.
  useEffect(() => {
    return () => {
      if (debounceTimer.current !== null) {
        clearTimeout(debounceTimer.current);
      }
    };
  }, []);

  const canSearch =
    destination !== null && (toggles.dispensary || toggles.munchies);

  const handleFindStops = useCallback(async () => {
    if (!canSearch || destination === null) return;
    // Defense-in-depth: never fetch dispensary data unless age-verified.
    if (!ageVerified) return;

    const token = ++findStopsToken.current;

    setErrorMessage(null);
    // Clear any stale results from a prior search so Results doesn't flash old data.
    setResults([]);
    setLoading(true);

    try {
      const effectiveOrigin: LatLng = origin ?? FALLBACK_ORIGIN;
      if (origin === null) {
        // TODO: wire up expo-location for real device position.
        console.warn(
          '[Home] Real geolocation is not yet wired up. Using SF fallback origin.',
        );
      }

      const corridor = routeCorridor(effectiveOrigin, destination.location);

      const [rawDispensaries, rawMunchies] = await Promise.all([
        toggles.dispensary ? findDispensariesInCorridor(corridor) : Promise.resolve([]),
        toggles.munchies ? findMunchiesInCorridor(corridor) : Promise.resolve([]),
      ]);

      if (findStopsToken.current !== token) return;

      const allStops = [...rawDispensaries, ...rawMunchies];

      const routeReqs: RouteRequest[] = allStops.map((stop) => ({
        origin: effectiveOrigin,
        destination: destination.location,
        waypoints: [stop.location],
      }));

      const baselineReq: RouteRequest = {
        origin: effectiveOrigin,
        destination: destination.location,
      };

      const [baselineResponse, ...stopResponses] = await getRouteBatch([
        baselineReq,
        ...routeReqs,
      ]);

      if (findStopsToken.current !== token) return;

      // No baseline means we can't compute detour cost — surface as an error
      // rather than silently ranking against a zero baseline.
      if (baselineResponse == null) {
        throw new Error('no baseline route');
      }

      const baselineSeconds = baselineResponse.duration.seconds;

      const durationsByStopId = new Map<string, number>();
      allStops.forEach((stop, idx) => {
        const resp = stopResponses[idx];
        if (resp !== null && resp !== undefined) {
          durationsByStopId.set(stop.id, resp.duration.seconds);
        }
      });

      const rankedDisp = rankCandidates(rawDispensaries, baselineSeconds, durationsByStopId);
      const rankedMunch = rankCandidates(rawMunchies, baselineSeconds, durationsByStopId);

      const pairDurations = new Map<string, number>();

      const combos = buildComboRoutes(rankedDisp, rankedMunch, baselineSeconds, pairDurations);

      if (findStopsToken.current !== token) return;

      setResults(combos);
      router.push('/results');
    } catch (err) {
      if (findStopsToken.current !== token) return;
      console.warn('[Home.handleFindStops] failed', err);
      setErrorMessage('something went wrong. try again.');
    } finally {
      if (findStopsToken.current === token) {
        setLoading(false);
      }
    }
  }, [ageVerified, canSearch, destination, origin, toggles, setLoading, setResults]);

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.container}>
        <Text style={styles.wordmark}>heybud</Text>

        <View style={styles.content}>
          <Text style={styles.heading}>where you headed?</Text>

          <DestinationInput
            value={query}
            onChangeText={handleChangeText}
            onSelectPlace={handleSelectPlace}
            suggestions={suggestions}
            placeholder="search a destination…"
          />

          <View style={styles.pills}>
            <Pill
              label="dispensary"
              selected={toggles.dispensary}
              onPress={() => toggleCategory('dispensary')}
              leadingGlyph="🌿"
              testID="pill-dispensary"
            />
            <View style={styles.pillGap} />
            <Pill
              label="munchies"
              selected={toggles.munchies}
              onPress={() => toggleCategory('munchies')}
              leadingGlyph="🍔"
              testID="pill-munchies"
            />
          </View>

          {errorMessage !== null ? (
            <Text style={styles.errorText} accessibilityLiveRegion="polite">
              {errorMessage}
            </Text>
          ) : null}
        </View>

        <View style={styles.footer}>
          <Button
            label="find stops"
            onPress={handleFindStops}
            variant="primary"
            disabled={!canSearch}
            loading={loading}
            testID="btn-find-stops"
          />
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: colors.bg,
  },
  container: {
    flex: 1,
    paddingHorizontal: spacing.xl,
    paddingTop: spacing.lg,
    paddingBottom: spacing.xxxl,
  },
  wordmark: {
    ...typography.heading,
    color: colors.accent,
    marginBottom: spacing.xl,
  },
  content: {
    flex: 1,
    gap: spacing.lg,
  },
  heading: {
    ...typography.title,
    color: colors.textPrimary,
  },
  pills: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  pillGap: {
    width: spacing.sm,
  },
  errorText: {
    ...typography.body,
    color: colors.error,
  },
  footer: {
    paddingTop: spacing.lg,
  },
});
