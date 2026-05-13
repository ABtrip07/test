import { TextStyle } from 'react-native';

const family = {
  regular: 'System',
  medium: 'System',
  semibold: 'System',
  bold: 'System',
};

export const typography = {
  display: {
    fontFamily: family.semibold,
    fontSize: 40,
    lineHeight: 44,
    letterSpacing: -1,
    fontWeight: '600',
  } satisfies TextStyle,
  title: {
    fontFamily: family.semibold,
    fontSize: 28,
    lineHeight: 32,
    letterSpacing: -0.5,
    fontWeight: '600',
  } satisfies TextStyle,
  heading: {
    fontFamily: family.medium,
    fontSize: 20,
    lineHeight: 24,
    fontWeight: '500',
  } satisfies TextStyle,
  body: {
    fontFamily: family.regular,
    fontSize: 16,
    lineHeight: 22,
    fontWeight: '400',
  } satisfies TextStyle,
  bodyMedium: {
    fontFamily: family.medium,
    fontSize: 16,
    lineHeight: 22,
    fontWeight: '500',
  } satisfies TextStyle,
  caption: {
    fontFamily: family.regular,
    fontSize: 13,
    lineHeight: 18,
    fontWeight: '400',
  } satisfies TextStyle,
  label: {
    fontFamily: family.medium,
    fontSize: 14,
    lineHeight: 18,
    letterSpacing: 0.2,
    fontWeight: '500',
  } satisfies TextStyle,
} as const;

export type TypographyToken = keyof typeof typography;
