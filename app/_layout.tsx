import { useEffect } from 'react';
import { Stack, useSegments, router } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { colors } from '@/theme/colors';
import { useAppStore } from '@/state/store';

// Global route guard: blocks any route other than the index (AgeGate)
// until ageVerified is true. Closes the deep-link bypass on /home and /results.
function RouteGuard() {
  const ageVerified = useAppStore((s) => s.ageVerified);
  const segments = useSegments();

  useEffect(() => {
    const first = segments[0];
    if (!ageVerified && first !== undefined && first.length > 0) {
      router.replace('/');
    }
  }, [ageVerified, segments]);

  return null;
}

export default function RootLayout() {
  return (
    <SafeAreaProvider>
      <StatusBar style="light" />
      <RouteGuard />
      <Stack
        screenOptions={{
          headerShown: false,
          contentStyle: { backgroundColor: colors.bg },
        }}
      />
    </SafeAreaProvider>
  );
}
