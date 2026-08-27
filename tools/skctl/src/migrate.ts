import { existsSync, mkdirSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import { installSkill } from "./install.ts";
import { loadRegistry } from "./registry.ts";
import { storePaths } from "./paths.ts";

export const DEFAULT_DOTFILES_SKILLS = "/home/xuqinqin/develop/dotfiles/agent/skills";

export function migrateLocal(dotfilesSkillsDir: string, store: string): string[] {
  const report: string[] = [];
  const p = storePaths(store);
  mkdirSync(p.skills, { recursive: true });
  const registry = loadRegistry(p.registry);
  if (!existsSync(dotfilesSkillsDir)) return report;
  for (const name of readdirSync(dotfilesSkillsDir)) {
    const src = join(dotfilesSkillsDir, name);
    if (!statSync(src).isDirectory()) continue;
    if (!existsSync(join(src, "SKILL.md"))) continue;
    if (registry.skills[name]) continue;
    installSkill({ src, store, ifExists: "skip" });
    report.push(`migrated (local): ${name}`);
  }
  return report;
}

export function migrateExternal(store: string): string[] {
  const report: string[] = [];
  const p = storePaths(store);
  const registry = loadRegistry(p.registry);
  for (const sub of ["skills/pdf", "skills/pptx"]) {
    const name = sub.split("/").pop()!;
    if (registry.skills[name]) continue;
    installSkill({ src: "https://github.com/anthropics/skills", subdir: sub, store, ifExists: "skip" });
    report.push(`installed (git): ${name}`);
  }
  return report;
}

export function migrate(store: string, dotfilesSkillsDir: string = DEFAULT_DOTFILES_SKILLS): string[] {
  const report = [...migrateLocal(dotfilesSkillsDir, store), ...migrateExternal(store)];
  report.push("next: commit dotfiles changes (remove agent/skills/pdf, agent/skills/pptx)");
  return report;
}