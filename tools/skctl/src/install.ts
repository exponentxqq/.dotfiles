import {
  cpSync, existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync,
  statSync, symlinkSync,
} from "node:fs";
import { join, resolve } from "node:path";
import { storePaths, USER_HOME } from "./paths.ts";
import { loadRegistry, saveRegistry } from "./registry.ts";
import { quote, run } from "./shell.ts";
import { parseFrontmatter, validateName } from "./validate.ts";

export const TMP_DIR = join(USER_HOME, ".cache", "agent-skills", "tmp");

export function findSkillDir(root: string): string | null {
  if (existsSync(join(root, "SKILL.md"))) return root;
  const candidates: string[] = [];
  for (const entry of readdirSync(root)) {
    const p = join(root, entry);
    if (statSync(p).isDirectory() && existsSync(join(p, "SKILL.md"))) {
      candidates.push(p);
    }
  }
  return candidates.length === 1 ? candidates[0] : null;
}

export interface InstallOptions {
  src: string;
  subdir?: string;
  store: string;
  ifExists?: "error" | "skip";
}

export function installSkill(opts: InstallOptions): string {
  const { src, subdir, store, ifExists = "error" } = opts;
  const p = storePaths(store);
  mkdirSync(p.skills, { recursive: true });
  mkdirSync(TMP_DIR, { recursive: true });
  const tmp = mkdtempSync(join(TMP_DIR, "install-"));
  try {
    let skillDir: string;
    let source: { type: "git" | "local"; url?: string; subdir?: string; path?: string };
    let commit: string | undefined;

    if (existsSync(src)) {
      const abs = resolve(src);
      if (!existsSync(join(abs, "SKILL.md"))) throw new Error(`no SKILL.md in ${abs}`);
      skillDir = abs;
      source = { type: "local", path: abs };
    } else if (src.endsWith(".zip")) {
      const zipPath = join(tmp, "skill.zip");
      const unzipDir = join(tmp, "unzipped");
      run(`curl -fsSL -o ${quote(zipPath)} ${quote(src)}`);
      run(`python3 -m zipfile -e ${quote(zipPath)} ${quote(unzipDir)}`);
      skillDir = subdir
        ? join(unzipDir, subdir)
        : findSkillDir(unzipDir) ?? fail("cannot locate SKILL.md in zip, use --subdir");
      source = { type: "local", url: src };
    } else {
      const repoDir = join(tmp, "repo");
      run(`git clone --depth 1 ${quote(src)} ${quote(repoDir)}`);
      skillDir = subdir
        ? join(repoDir, subdir)
        : findSkillDir(repoDir) ?? fail("cannot locate SKILL.md, use --subdir");
      commit = run(`git -C ${quote(repoDir)} rev-parse HEAD`);
      source = { type: "git", url: src, subdir };
    }

    const fm = parseFrontmatter(readFileSync(join(skillDir, "SKILL.md"), "utf8"));
    if (!fm) throw new Error("invalid SKILL.md frontmatter");
    if (!validateName(fm.name)) throw new Error(`invalid skill name: ${fm.name}`);
    const name = fm.name;
    const dest = join(p.skills, name);
    if (existsSync(dest)) {
      if (ifExists === "skip") return name;
      throw new Error(`skill already installed: ${name}`);
    }
    if (source.type === "local" && source.path) {
      symlinkSync(skillDir, dest);
    } else {
      cpSync(skillDir, dest, { recursive: true, filter: (src) => !src.split("/").includes(".git") });
    }
    const registry = loadRegistry(p.registry);
    registry.skills[name] = {
      source,
      installedCommit: commit,
      installedAt: new Date().toISOString(),
    };
    saveRegistry(p.registry, registry);
    return name;
  } finally {
    rmSync(tmp, { recursive: true, force: true });
  }
}

function fail(msg: string): never {
  throw new Error(msg);
}