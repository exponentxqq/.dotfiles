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

export function makeColor(enabled: boolean): Color {
  const wrap = (code: string) => (s: string) => (enabled ? `\x1b[${code}m${s}\x1b[0m` : s);
  return {
    green: wrap("32"),
    red: wrap("31"),
    yellow: wrap("33"),
    bold: wrap("1"),
    dim: wrap("2"),
    cyan: wrap("36"),
    magenta: wrap("35"),
  };
}