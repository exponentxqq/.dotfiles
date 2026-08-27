import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

export const DEFAULT_STORE = join(homedir(), ".local", "share", "agent-skills");
export const CONFIG_PATH = join(homedir(), ".config", "agent-skills", "config.json");

export function resolveStore(storeFlag?: string, configPath: string = CONFIG_PATH): string {
  if (storeFlag) return storeFlag;
  try {
    const cfg = JSON.parse(readFileSync(configPath, "utf8")) as { store?: string };
    return cfg.store ?? DEFAULT_STORE;
  } catch {
    return DEFAULT_STORE;
  }
}

export function storePaths(store: string) {
  return {
    store,
    skills: join(store, "skills"),
    disabled: join(store, "skills-disabled"),
    registry: join(store, "registry.json"),
  };
}