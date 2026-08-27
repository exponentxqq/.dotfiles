import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";

export type SourceType = "git" | "local";

export interface SkillSource {
  type: SourceType;
  url?: string;
  subdir?: string;
  path?: string;
}

export interface SkillRecord {
  source: SkillSource;
  installedCommit?: string;
  installedAt: string;
}

export interface Registry {
  skills: Record<string, SkillRecord>;
}

export function loadRegistry(registryPath: string): Registry {
  try {
    return JSON.parse(readFileSync(registryPath, "utf8")) as Registry;
  } catch {
    return { skills: {} };
  }
}

export function saveRegistry(registryPath: string, registry: Registry): void {
  mkdirSync(dirname(registryPath), { recursive: true });
  writeFileSync(registryPath, JSON.stringify(registry, null, 2) + "\n");
}
