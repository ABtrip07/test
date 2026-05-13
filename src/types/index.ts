export type StopCategory = 'dispensary' | 'munchies';

export interface LatLng {
  lat: number;
  lng: number;
}

export interface Place {
  id: string;
  name: string;
  address: string;
  location: LatLng;
}

export interface Stop {
  id: string;
  name: string;
  category: StopCategory;
  location: LatLng;
  address: string;
  rating?: number;
  openNow?: boolean;
  subtype?: string;
}

export interface RankedStop extends Stop {
  detourMinutes: number;
}

export interface ComboRoute {
  id: string;
  stops: RankedStop[];
  totalDetourMinutes: number;
  baselineMinutes: number;
  totalMinutes: number;
}

export type Duration = {
  seconds: number;
};
