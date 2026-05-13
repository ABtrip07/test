import { Redirect } from 'expo-router';

import { AgeGate } from '@/screens/AgeGate';
import { useAppStore } from '@/state/store';

export default function Index() {
  const ageVerified = useAppStore((s) => s.ageVerified);

  if (ageVerified) {
    return <Redirect href="/home" />;
  }

  return <AgeGate />;
}
