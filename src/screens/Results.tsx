import React, { useCallback } from 'react';
import {
  View,
  Text,
  FlatList,
  ActivityIndicator,
  StyleSheet,
  Pressable,
  Linking,
  Platform,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';

import { StopCard } from '@/components/StopCard';
import { colors } from '@/theme/colors';
import { typography } from '@/theme/typography';
import { spacing, radius } from '@/theme/spacing';
import { useAppStore } from '@/state/store';
import { formatMinutes } from '@/routing/detour';
import type { ComboRoute, LatLng } from '@/types';

function buildMapsUrl(
  combo: ComboRoute,
  destination: LatLng | null,
  destinationName: string,
): string {
  if (!combo || !Array.isArray(combo.stops) || combo.stops.length === 0) return '';
  if (destination === null) return '';

  const stops = combo.stops;

  if (Platform.OS === 'ios') {
    // Apple Maps: chain stops then the final destination as the last daddr segment.
    const segments = [
      ...stops.map((s) => `${s.location.lat},${s.location.lng}`),
      `${destination.lat},${destination.lng}`,
    ].join('+to:');
    return `maps://?saddr=My+Location&daddr=${segments}&dirflg=d`;
  }

  const waypointsParam = stops
    .map((s) => `${s.location.lat},${s.location.lng}`)
    .join('|');
  const destParam = `${destination.lat},${destination.lng}`;
  const encodedName = encodeURIComponent(destinationName);
  return `https://www.google.com/maps/dir/?api=1&destination=${destParam}&destination_place_id=&waypoints=${waypointsParam}&travelmode=driving&dir_action=navigate#${encodedName}`;
}

// ---------------------------------------------------------------------------
// ComboCard
// ---------------------------------------------------------------------------

interface ComboCardProps {
  combo: ComboRoute;
  destination: LatLng | null;
  destinationName: string;
}

function ComboCard({ combo, destination, destinationName }: ComboCardProps) {
  if (!combo || !Array.isArray(combo.stops) || combo.stops.length === 0) {
    return null;
  }

  async function handlePress() {
    try {
      const url = buildMapsUrl(combo, destination, destinationName);
      if (!url) return;

      const supported = await Linking.canOpenURL(url);
      if (supported) {
        await Linking.openURL(url);
      } else if (destination !== null) {
        const destParam = `${destination.lat},${destination.lng}`;
        const waypointsParam = combo.stops
          .map((s) => `${s.location.lat},${s.location.lng}`)
          .join('|');
        const fallback = `https://www.google.com/maps/dir/?api=1&destination=${destParam}&waypoints=${waypointsParam}&travelmode=driving`;
        await Linking.openURL(fallback);
      }
    } catch (err) {
      console.warn('[Results.ComboCard] failed to open maps', err);
    }
  }

  return (
    <Pressable
      style={({ pressed }) => [styles.comboCard, pressed && styles.comboCardPressed]}
      onPress={handlePress}
      accessibilityRole="button"
      accessibilityLabel={`Open route with ${combo.stops.map((s) => s.name ?? '').filter(Boolean).join(' and ')} in Maps`}
    >
      {combo.stops.map((stop, idx) => (
        <View key={stop.id ?? idx}>
          {idx > 0 ? <View style={styles.stopDivider} /> : null}
          <StopCard stop={stop} />
        </View>
      ))}
      <Text style={styles.comboTotal}>
        {formatMinutes(combo.totalDetourMinutes)} total detour · tap to open in Maps
      </Text>
    </Pressable>
  );
}

// ---------------------------------------------------------------------------
// Results screen
// ---------------------------------------------------------------------------

export function Results() {
  const loading = useAppStore((s) => s.loading);
  const results = useAppStore((s) => s.results);
  const destination = useAppStore((s) => s.destination);

  const destinationName = destination?.name ?? 'destination';
  const destinationLocation: LatLng | null = destination?.location ?? null;

  // Best combo is the first (lowest detour) after ranking.
  const bestCombo = Array.isArray(results) ? results[0] : undefined;

  const handleBack = useCallback(() => {
    router.back();
  }, []);

  // ---- Loading state ----
  if (loading) {
    return (
      <SafeAreaView style={styles.safe}>
        <View style={styles.centered}>
          <ActivityIndicator size="large" color={colors.accent} />
          <Text style={styles.loadingText}>finding stops…</Text>
        </View>
      </SafeAreaView>
    );
  }

  // ---- Empty state ----
  if (!Array.isArray(results) || results.length === 0) {
    return (
      <SafeAreaView style={styles.safe}>
        <View style={styles.container}>
          <View style={styles.topBar}>
            <Pressable
              onPress={handleBack}
              style={styles.backButton}
              accessibilityRole="button"
              accessibilityLabel="Back"
            >
              <Text style={styles.backLabel}>‹ back</Text>
            </Pressable>
            <Text style={styles.destinationLabel} numberOfLines={1}>
              {destinationName}
            </Text>
          </View>
          <View style={styles.centered}>
            <Text style={styles.emptyText}>
              no stops found on this route. try toggling a category.
            </Text>
            <Pressable
              onPress={handleBack}
              style={styles.emptyBackButton}
              accessibilityRole="button"
              accessibilityLabel="Back"
            >
              <Text style={styles.emptyBackLabel}>back</Text>
            </Pressable>
          </View>
        </View>
      </SafeAreaView>
    );
  }

  // ---- Results ----
  // Show the count of stops in the best combo + its total detour.
  const bestStopCount = bestCombo?.stops?.length ?? 0;
  const summaryText =
    bestStopCount === 1
      ? `1 stop on your route · ${formatMinutes(bestCombo?.totalDetourMinutes ?? 0)} total`
      : `${bestStopCount} stops on your route · ${formatMinutes(bestCombo?.totalDetourMinutes ?? 0)} total`;

  function renderItem({ item }: { item: ComboRoute }) {
    return (
      <ComboCard
        combo={item}
        destination={destinationLocation}
        destinationName={destinationName}
      />
    );
  }

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.container}>
        <View style={styles.topBar}>
          <Pressable
            onPress={handleBack}
            style={styles.backButton}
            accessibilityRole="button"
            accessibilityLabel="Back"
          >
            <Text style={styles.backLabel}>‹ back</Text>
          </Pressable>
          <Text style={styles.destinationLabel} numberOfLines={1}>
            {destinationName}
          </Text>
        </View>

        <Text style={styles.summary}>{summaryText}</Text>

        <FlatList<ComboRoute>
          data={results}
          keyExtractor={(item, index) => item?.id ?? `combo-${index}`}
          renderItem={renderItem}
          ItemSeparatorComponent={() => <View style={styles.listSeparator} />}
          contentContainerStyle={styles.listContent}
          showsVerticalScrollIndicator={false}
          keyboardShouldPersistTaps="handled"
        />
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
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    gap: spacing.lg,
    paddingHorizontal: spacing.xl,
  },
  topBar: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.lg,
    gap: spacing.md,
  },
  backButton: {
    paddingVertical: spacing.xs,
    paddingRight: spacing.sm,
  },
  backLabel: {
    ...typography.bodyMedium,
    color: colors.accent,
  },
  destinationLabel: {
    ...typography.heading,
    color: colors.textPrimary,
    flex: 1,
  },
  summary: {
    ...typography.body,
    color: colors.textSecondary,
    marginBottom: spacing.lg,
  },
  listContent: {
    paddingBottom: spacing.xxxl,
  },
  listSeparator: {
    height: spacing.md,
  },
  comboCard: {
    backgroundColor: colors.surface,
    borderRadius: radius.lg,
    padding: spacing.lg,
    gap: spacing.sm,
  },
  comboCardPressed: {
    opacity: 0.75,
  },
  stopDivider: {
    height: spacing.sm,
  },
  comboTotal: {
    ...typography.caption,
    color: colors.textMuted,
    marginTop: spacing.xs,
    textAlign: 'right',
  },
  loadingText: {
    ...typography.body,
    color: colors.textSecondary,
    marginTop: spacing.md,
  },
  emptyText: {
    ...typography.body,
    color: colors.textSecondary,
    textAlign: 'center',
  },
  emptyBackButton: {
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.xl,
  },
  emptyBackLabel: {
    ...typography.bodyMedium,
    color: colors.accent,
  },
});
