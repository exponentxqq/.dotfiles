export type ColorFn = (s: string) => string;

export interface Color {
  green: ColorFn;
  red: ColorFn;
  yellow: ColorFn;
  bold: ColorFn;
  dim: ColorFn;
  cyan: ColorFn;
  magenta: ColorFn;
}

import { createColors } from "picocolors";

export const makeColor = (enabled: boolean): Color => {
  const c = createColors(enabled);
  const normalize = (fn: ColorFn): ColorFn => (s) =>
    fn(s).replace(/\x1b\[39m/g, "\x1b[0m").replace(/\x1b\[22m/g, "\x1b[0m");
  return {
    green: normalize(c.green),
    red: normalize(c.red),
    yellow: normalize(c.yellow),
    bold: normalize(c.bold),
    dim: normalize(c.dim),
    cyan: normalize(c.cyan),
    magenta: normalize(c.magenta),
  };
};