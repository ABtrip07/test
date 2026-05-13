import React from 'react';
import { Pressable, Text, StyleSheet, View } from 'react-native';
import * as Haptics from 'expo-haptics';
import { colors } from '../theme/colors';
import { typography } from '../theme/typography';
import { spacing, radius } from '../theme/spacing';

interface PillProps {
  label: string;
  selected: boolean;
  onPress: () => void;
  leadingGlyph?: string;
  testID?: string;
}

export function Pill({ label, selected, onPress, leadingGlyph, testID }: PillProps) {
  async function handlePress() {
    try {
      await Haptics.selectionAsync();
    } catch {
      // Haptics unsupported on this platform — silent fail
    }
    onPress();
  }

  return (
    <Pressable
      testID={testID}
      onPress={handlePress}
      style={({ pressed }) => [
        styles.pill,
        selected ? styles.pillSelected : styles.pillUnselected,
        pressed && styles.pillPressed,
      ]}
      accessibilityRole="button"
      accessibilityState={{ selected }}
    >
      {leadingGlyph ? (
        <Text style={[styles.glyph, selected ? styles.textSelected : styles.textUnselected]}>
          {leadingGlyph}
        </Text>
      ) : null}
      <Text style={[styles.label, selected ? styles.textSelected : styles.textUnselected]}>
        {label ?? ''}
      </Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  pill: {
    flexDirection: 'row',
    alignItems: 'center',
    minHeight: 44,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderRadius: radius.pill,
    alignSelf: 'flex-start',
  },
  pillSelected: {
    backgroundColor: colors.accent,
  },
  pillUnselected: {
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
  },
  pillPressed: {
    opacity: 0.75,
  },
  label: {
    ...typography.label,
  },
  glyph: {
    ...typography.label,
    marginRight: spacing.xs,
  },
  textSelected: {
    color: colors.accentText,
  },
  textUnselected: {
    color: colors.textPrimary,
  },
});
