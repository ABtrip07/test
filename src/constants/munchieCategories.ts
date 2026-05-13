export const MUNCHIE_CATEGORIES = [
  'fast_food',
  'convenience_store',
  'pizza',
  'ice_cream',
  'donut',
  'ramen',
  'boba',
  'late_night',
  'gas_station_hot_food',
] as const;

export type MunchieCategory = (typeof MUNCHIE_CATEGORIES)[number];

export const MUNCHIE_LABELS: Record<MunchieCategory, string> = {
  fast_food: 'Fast food',
  convenience_store: 'Convenience',
  pizza: 'Pizza',
  ice_cream: 'Ice cream',
  donut: 'Donuts',
  ramen: 'Ramen',
  boba: 'Boba',
  late_night: 'Late night',
  gas_station_hot_food: 'Gas station',
};
