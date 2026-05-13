import React from 'react';
import {
  View,
  TextInput,
  Text,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';
import { colors } from '../theme/colors';
import { typography } from '../theme/typography';
import { spacing, radius } from '../theme/spacing';
import type { Place } from '../types';

interface DestinationInputProps {
  value: string;
  onChangeText: (s: string) => void;
  onSelectPlace?: (place: Place) => void;
  suggestions?: Place[];
  placeholder?: string;
}

export function DestinationInput({
  value,
  onChangeText,
  onSelectPlace,
  suggestions,
  placeholder = 'where to?',
}: DestinationInputProps) {
  // Guard: treat missing/malformed suggestions as empty
  const safeSuggestions: Place[] = Array.isArray(suggestions) ? suggestions : [];
  const showDropdown = safeSuggestions.length > 0 && (value ?? '').length > 0;

  return (
    <View style={styles.container}>
      <TextInput
        style={styles.input}
        value={value ?? ''}
        onChangeText={onChangeText}
        placeholder={placeholder}
        placeholderTextColor={colors.textMuted}
        returnKeyType="search"
        autoCorrect={false}
        autoCapitalize="words"
        maxLength={120}
        underlineColorAndroid="transparent"
        selectionColor={colors.accent}
        accessibilityLabel="Destination search"
      />
      {showDropdown && (
        <View style={styles.dropdown}>
          {safeSuggestions.map((place, index) => {
            // Guard: skip malformed suggestion entries
            if (!place?.id) return null;

            return (
              <TouchableOpacity
                key={place.id}
                style={[
                  styles.suggestionRow,
                  index < safeSuggestions.length - 1 && styles.suggestionDivider,
                ]}
                onPress={() => onSelectPlace?.(place)}
                activeOpacity={0.7}
                accessibilityRole="button"
                accessibilityLabel={`Select ${place.name ?? 'location'}`}
              >
                <Text style={styles.suggestionName} numberOfLines={1}>
                  {place.name ?? ''}
                </Text>
                {(place.address ?? '').length > 0 && (
                  <Text style={styles.suggestionAddress} numberOfLines={1}>
                    {place.address}
                  </Text>
                )}
              </TouchableOpacity>
            );
          })}
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    width: '100%',
  },
  input: {
    ...typography.body,
    color: colors.textPrimary,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.md,
    minHeight: 52,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
  },
  dropdown: {
    backgroundColor: colors.surfaceElevated,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.md,
    marginTop: spacing.xs,
    overflow: 'hidden',
  },
  suggestionRow: {
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    minHeight: 52,
    justifyContent: 'center',
  },
  suggestionDivider: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.border,
  },
  suggestionName: {
    ...typography.bodyMedium,
    color: colors.textPrimary,
  },
  suggestionAddress: {
    ...typography.caption,
    color: colors.textSecondary,
    marginTop: spacing.xxs,
  },
});
