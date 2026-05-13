import React from 'react';
import { Pressable, View, Text, StyleSheet } from 'react-native';
import { colors } from '../theme/colors';
import { typography } from '../theme/typography';
import { spacing, radius } from '../theme/spacing';
import type { RankedStop } from '../types';

interface StopCardProps {
  stop: RankedStop;
  onPress?: () => void;
}

// Derives the left-edge accent color from the stop category.
// Defaults to border color for any unexpected/missing category value.
function categoryColor(category: RankedStop['category'] | undefined): string {
  if (category === 'dispensary') return colors.dispensary;
  if (category === 'munchies') return colors.munchies;
  return colors.border;
}

function formatDetour(minutes: number | undefined): string {
  if (minutes == null || !Number.isFinite(minutes)) return '';
  const rounded = Math.round(minutes);
  return `+${rounded} min`;
}

function formatRating(rating: number | undefined): string {
  if (rating == null || !Number.isFinite(rating)) return '';
  return rating.toFixed(1);
}

export function StopCard({ stop, onPress }: StopCardProps) {
  // Robustness: never crash if stop is unexpectedly null/undefined
  if (!stop) return null;

  const detourLabel = formatDetour(stop.detourMinutes);
  const ratingLabel = formatRating(stop.rating);
  const accentBar = categoryColor(stop.category);

  const hasOpenStatus = stop.openNow != null;
  const dotColor = stop.openNow ? colors.success : colors.textMuted;

  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [styles.card, pressed && onPress && styles.cardPressed]}
      accessibilityRole="button"
      accessibilityLabel={[stop.name, stop.address, detourLabel].filter(Boolean).join(', ')}
    >
      {/* Category accent bar */}
      <View style={[styles.categoryBar, { backgroundColor: accentBar }]} />

      {/* Main content */}
      <View style={styles.body}>
        <View style={styles.nameRow}>
          <Text style={styles.name} numberOfLines={1}>
            {stop.name ?? ''}
          </Text>
        </View>
        {(stop.address ?? '').length > 0 && (
          <Text style={styles.address} numberOfLines={1}>
            {stop.address}
          </Text>
        )}
      </View>

      {/* Right-side metrics */}
      <View style={styles.meta}>
        {detourLabel.length > 0 && (
          <Text style={styles.detour}>{detourLabel}</Text>
        )}
        <View style={styles.metaSecondary}>
          {ratingLabel.length > 0 && (
            <Text style={styles.rating}>{ratingLabel}</Text>
          )}
          {hasOpenStatus && (
            <View style={[styles.openDot, { backgroundColor: dotColor }]} />
          )}
        </View>
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.surface,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
    minHeight: 72,
    overflow: 'hidden',
  },
  cardPressed: {
    opacity: 0.75,
  },
  categoryBar: {
    width: 4,
    alignSelf: 'stretch',
  },
  body: {
    flex: 1,
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
    justifyContent: 'center',
    gap: spacing.xxs,
  },
  nameRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  name: {
    ...typography.bodyMedium,
    color: colors.textPrimary,
    flexShrink: 1,
  },
  address: {
    ...typography.caption,
    color: colors.textSecondary,
  },
  meta: {
    alignItems: 'flex-end',
    justifyContent: 'center',
    paddingVertical: spacing.md,
    paddingRight: spacing.lg,
    paddingLeft: spacing.sm,
    gap: spacing.xxs,
  },
  detour: {
    ...typography.label,
    color: colors.accent,
  },
  metaSecondary: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.xs,
  },
  rating: {
    ...typography.caption,
    color: colors.textSecondary,
  },
  openDot: {
    width: 7,
    height: 7,
    borderRadius: radius.pill,
  },
});
