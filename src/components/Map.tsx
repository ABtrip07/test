import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors } from '@/theme/colors';
import { typography } from '@/theme/typography';
import { spacing, radius } from '@/theme/spacing';
import type { LatLng, RankedStop } from '@/types';

export interface MapProps {
  origin: LatLng | null;
  destination: LatLng | null;
  stops: RankedStop[];
  style?: object;
}

// Placeholder map surface. Real rendering will be wired up via @rnmapbox/maps
// on native and mapbox-gl on web once an EXPO_PUBLIC_MAPBOX_ACCESS_TOKEN
// is provisioned. Splitting into Map.native.tsx and Map.web.tsx is the
// recommended path — Metro picks the right file per platform.
export function Map({ origin, destination, stops, style }: MapProps) {
  const stopCount = Array.isArray(stops) ? stops.length : 0;

  return (
    <View style={[styles.container, style]}>
      <View style={styles.placeholderContent}>
        <Text style={styles.placeholderTitle}>map</Text>
        <Text style={styles.placeholderHint}>
          {origin === null || destination === null
            ? 'set an origin and destination'
            : `${stopCount} ${stopCount === 1 ? 'stop' : 'stops'} on route`}
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: colors.surface,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
    minHeight: 200,
    overflow: 'hidden',
  },
  placeholderContent: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    gap: spacing.xs,
    padding: spacing.lg,
  },
  placeholderTitle: {
    ...typography.label,
    color: colors.textMuted,
    textTransform: 'lowercase',
  },
  placeholderHint: {
    ...typography.caption,
    color: colors.textMuted,
  },
});
