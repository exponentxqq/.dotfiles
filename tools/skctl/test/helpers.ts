export const quote = (s: string) => "'" + s.replace(/'/g, "'\\''") + "'";
