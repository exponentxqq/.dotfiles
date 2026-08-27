import { cpSync, existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, statSync } from "node:fs";
import { join, relative } from "node:path";
import { simpleGit } from "simple-git";
import { findSkillDir, TMP_DIR } from "./install.ts";
import { loadRegistry, saveRegistry } from "./registry.ts";
import { storePaths } from "./paths.ts";

export async function updateSkill(name: string, store: string): Promise<string> {
  const p = storePaths(store);
  const registry = loadRegistry(p.registry);
  const rec = registry.skills[name];
  if (!rec) throw new Error(`not installed: ${name}`);
  if (rec.source.type !== "git") return "skipped (local source)";
  const dest = join(p.skills, name);
  if (!existsSync(dest)) throw new Error(`skill dir missing: ${name}`);
  mkdirSync(TMP_DIR, { recursive: true });
  const tmp = mkdtempSync(join(TMP_DIR, "update-"));
  try {
    const repoDir = join(tmp, "repo");
    await simpleGit().clone(rec.source.url!, repoDir, ["--depth", "1"]);
    const newCommit = await simpleGit(repoDir).revparse("HEAD");
    if (newCommit === rec.installedCommit) return "up-to-date";
    const skillDir = rec.source.subdir
      ? join(repoDir, rec.source.subdir)
      : findSkillDir(repoDir) ?? fail("cannot locate SKILL.md");
    const changed = diffFiles(dest, skillDir);
    if (changed.length > 0) {
      console.log(`  local modifications will be overwritten: ${changed.join(", ")}`);
    }
    const oldCommit = rec.installedCommit;
    rmSync(dest, { recursive: true, force: true });
    cpSync(skillDir, dest, { recursive: true, filter: (src) => !src.split("/").includes(".git") });
    rec.installedCommit = newCommit;
    rec.installedAt = new Date().toISOString();
    saveRegistry(p.registry, registry);
    return `updated: ${(oldCommit ?? "").slice(0, 7)} -> ${newCommit.slice(0, 7)}`;
  } finally {
    rmSync(tmp, { recursive: true, force: true });
  }
}

function diffFiles(a: string, b: string): string[] {
  const changed: string[] = [];
  const walk = (dir: string, base: string) => {
    for (const entry of readdirSync(dir)) {
      const p = join(dir, entry);
      const rel = relative(base, p);
      const other = join(b, rel);
      if (statSync(p).isDirectory()) {
        walk(p, base);
      } else if (!existsSync(other) || !readFileSync(p).equals(readFileSync(other))) {
        changed.push(rel);
      }
    }
  };
  walk(a, a);
  return changed;
}

function fail(msg: string): never {
  throw new Error(msg);
}