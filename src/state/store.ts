import { create } from 'zustand';
import type { ComboRoute, LatLng, Place, StopCategory } from '@/types';

type Toggles = Record<StopCategory, boolean>;

interface AppState {
  ageVerified: boolean;
  origin: LatLng | null;
  destination: Place | null;
  toggles: Toggles;
  results: ComboRoute[];
  loading: boolean;

  verifyAge: () => void;
  setOrigin: (origin: LatLng | null) => void;
  setDestination: (place: Place | null) => void;
  toggleCategory: (category: StopCategory) => void;
  setResults: (results: ComboRoute[]) => void;
  setLoading: (loading: boolean) => void;
  reset: () => void;
}

const initialToggles: Toggles = { dispensary: true, munchies: true };

export const useAppStore = create<AppState>((set) => ({
  ageVerified: false,
  origin: null,
  destination: null,
  toggles: initialToggles,
  results: [],
  loading: false,

  verifyAge: () => set({ ageVerified: true }),
  setOrigin: (origin) => set({ origin }),
  setDestination: (destination) => set({ destination }),
  toggleCategory: (category) =>
    set((state) => ({
      toggles: { ...state.toggles, [category]: !state.toggles[category] },
    })),
  setResults: (results) => set({ results }),
  setLoading: (loading) => set({ loading }),
  reset: () =>
    set({
      destination: null,
      results: [],
      loading: false,
      toggles: initialToggles,
    }),
}));
