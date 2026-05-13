import React, { useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';

import { Button } from '@/components/Button';
import { colors } from '@/theme/colors';
import { typography } from '@/theme/typography';
import { spacing } from '@/theme/spacing';
import { useAppStore } from '@/state/store';

export function AgeGate() {
  const [declined, setDeclined] = useState(false);

  function handleVerify() {
    // Call via getState so verifyAge is not captured as a stale closure.
    useAppStore.getState().verifyAge();
    router.replace('/home');
  }

  function handleDecline() {
    setDeclined(true);
  }

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.container}>
        <View style={styles.hero}>
          <Text style={styles.wordmark}>heybud</Text>
          <Text style={styles.tagline}>dispensaries and munchies, on the way.</Text>
        </View>

        <View style={styles.gateBlock}>
          <Text style={styles.requirement}>you must be 21 or older to use heybud.</Text>

          {declined ? (
            <Text style={styles.deniedMessage} accessibilityLiveRegion="polite">
              sorry, you can't use heybud yet.
            </Text>
          ) : null}

          <View style={styles.buttons}>
            <Button
              label="i'm 21 or older"
              onPress={handleVerify}
              variant="primary"
              disabled={declined}
              testID="age-gate-verify"
            />
            <View style={styles.buttonGap} />
            <Button
              label="i'm not"
              onPress={handleDecline}
              variant="secondary"
              testID="age-gate-decline"
            />
          </View>
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
    justifyContent: 'space-between',
    paddingBottom: spacing.xxxl,
  },
  hero: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    gap: spacing.md,
  },
  wordmark: {
    ...typography.display,
    color: colors.accent,
    textAlign: 'center',
  },
  tagline: {
    ...typography.body,
    color: colors.textSecondary,
    textAlign: 'center',
  },
  gateBlock: {
    gap: spacing.lg,
  },
  requirement: {
    ...typography.bodyMedium,
    color: colors.textPrimary,
    textAlign: 'center',
  },
  deniedMessage: {
    ...typography.body,
    color: colors.error,
    textAlign: 'center',
  },
  buttons: {
    width: '100%',
  },
  buttonGap: {
    height: spacing.md,
  },
});
