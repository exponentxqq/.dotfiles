import { execSync } from "node:child_process";

export function quote(s: string): string {
  return "'" + s.replace(/'/g, `'\\''`) + "'";
}

export function run(cmd: string): string {
  return execSync(cmd, { stdio: ["ignore", "pipe", "pipe"] }).toString().trim();
}