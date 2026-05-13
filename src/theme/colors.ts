export const colors = {
  bg: '#0A0A0A',
  surface: '#141414',
  surfaceElevated: '#1C1C1C',
  border: '#262626',

  textPrimary: '#F5F1EA',
  textSecondary: '#9C968C',
  textMuted: '#5C5851',

  accent: '#D89B4A',
  accentMuted: '#7A5A2B',
  accentText: '#0A0A0A',

  dispensary: '#C9A66B',
  munchies: '#E08A5C',

  success: '#6B8F62',
  error: '#D9534F',

  overlay: 'rgba(10, 10, 10, 0.72)',
} as const;

export type ColorToken = keyof typeof colors;
