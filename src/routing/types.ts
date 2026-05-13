import type { Duration, LatLng, Stop } from '@/types';

export interface RouteRequest {
  origin: LatLng;
  destination: LatLng;
  waypoints?: LatLng[];
}

export interface RouteResponse {
  duration: Duration;
  distanceMeters: number;
  polyline?: string;
}

export interface Corridor {
  minLat: number;
  maxLat: number;
  minLng: number;
  maxLng: number;
}

export interface CandidateDuration {
  stop: Stop;
  duration: Duration;
}
